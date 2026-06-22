provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source           = "../modules/ecr"
  repository_name  = var.ecr_repository_name
  env              = var.env
}

module "ecs_task_execution_role" {
  source              = "../modules/IAM"
  role_name           = "ecs-task-execution-role"
  env              = var.env
  policy_name         = "ecs-task-execution-policy"
  policy_description  = "Policy for ECS task execution role"
  bucket_arn         = module.s3_bucket.bucket_arn
  assume_role_policy  = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  policy_statements = [
    {
      Effect   = "Allow"
      Action   = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [module.snowflake_secret.secret_arn]
    }
  ]
} 
module "task_role" {
  source             = "../modules/IAM"
  role_name          = "task-role"
  env              = var.env
  policy_name        = "dbt-taskrole-policy"
  policy_description = "Policy for ecs task role"
  bucket_arn         = module.s3_bucket2.bucket_arn
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  
  policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
      module.s3_bucket2.bucket_arn,          # Bucket ARN
      "${module.s3_bucket2.bucket_arn}/*"    # Bucket ARN with objects
    ]
    }
  ]
}

module "mwaa_role" {
  source             = "../modules/IAM"
  role_name          = "mwaa-role"
  env              = var.env
  policy_name        = "mwaa-policy"
  policy_description = "Policy for MWAA"
  bucket_arn         = module.s3_bucket.bucket_arn
  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "airflow-env.amazonaws.com",
            "airflow.amazonaws.com"
          ]
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  }
  
  policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutObject"
      ]
      Resource = [
      module.s3_bucket.bucket_arn,          # Bucket ARN
      "${module.s3_bucket.bucket_arn}/*"    # Bucket ARN with objects
    ]
    },
    {
      Effect = "Allow"
      Action = [
        "ecs:RunTask",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:StopTask",
        "iam:PassRole",
        "ecs:ListClusters",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
         "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = ["*"]
    },
    {
      Effect = "Deny"
      Action = ["s3:ListAllMyBuckets"]
      Resource = [
      module.s3_bucket.bucket_arn,          # Bucket ARN
      "${module.s3_bucket.bucket_arn}/*"    # Bucket ARN with objects....
    ]
    },
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject*",
        "s3:GetBucket*",
        "s3:List*"
      ]
      Resource = [
      module.s3_bucket.bucket_arn,          # Bucket ARN
      "${module.s3_bucket.bucket_arn}/*"    # Bucket ARN with objects
    ]
    },
    {
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:GetLogRecord",
        "logs:GetLogGroupFields",
        "logs:GetQueryResults",
        "logs:DescribeLogStreams"
      ]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = [
        "logs:DescribeLogGroups"
      ]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = ["cloudwatch:PutMetricData"]
      Resource = ["*"]
    },
    {
      Effect = "Allow"
      Action = [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ]
      Resource = ["*"]
     },
    {
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Encrypt"
      ]
      #NotResource = ["arn:aws-cn:kms:*:216962084862:key/*"]
      Resource = ["*"]
      # Condition = {
      # StringLike = {
      #   "kms:ViaService" = "sqs.cn-northwest-1.amazonaws.com"
      #   }
      # }
    },
    {
      "Effect": "Allow",
      "Action": ["sns:Publish"],
      "Resource": [module.sns_notifications.sns_topic_arn]
    }
  ]
}

module "snowflake_secret" {
    source       = "../modules/secrets"
    env              = var.env
    secret_name = var.my_secret_name
    snowflake_account   = var.snowflake_account
    snowflake_user      = var.snowflake_user
    snowflake_password  = var.snowflake_password
    maximo_user      = var.maximo_user
    maximo_password  = var.maximo_password
}  

module "ecs" {
  source             = "../modules/ecs"
  env                = var.env
  cluster_name       = var.ecs_cluster_name
  vpc_id             = data.aws_vpc.selected.id
  family_name        = var.ecs_family_name
  execution_role_arn = module.ecs_task_execution_role.execution_role_arn #getting this role from output
  task_role_arn      = module.task_role.execution_role_arn #getting this role from output
  cpu                = var.cpu 
  memory             = var.memory 
  container_name     = var.ecs_container_name
  container_image    = module.ecr.repository_url != "" ? "${module.ecr.repository_url}:latest" : "amazonlinux:latest"  # Use the image from ECR if available
  subnet_ids         = [data.aws_subnet.private_subnet_1a.id, data.aws_subnet.private_subnet_1b.id]
  # ecs_secrets        = var.ecs_secrets
  ecs_secrets = [
    {
      name      = "SNOWFLAKE_ACCOUNT"
      valueFrom = "${module.snowflake_secret.secret_arn}:SNOWFLAKE_ACCOUNT::"
    },
    {
      name      = "SNOWFLAKE_USER"
      valueFrom = "${module.snowflake_secret.secret_arn}:SNOWFLAKE_USER::"
    },
    {
      name      = "SNOWFLAKE_PASSWORD"
      valueFrom = "${module.snowflake_secret.secret_arn}:SNOWFLAKE_PASSWORD::"
    },
        {
      name      = "MAXIMO_USER"
      valueFrom = "${module.snowflake_secret.secret_arn}:SNOWFLAKE_USER::"
    },
    {
      name      = "MAXIMO_PASSWORD"
      valueFrom = "${module.snowflake_secret.secret_arn}:SNOWFLAKE_PASSWORD::"
    }

  ]

  env_var = []
  log_region         = var.aws_region
  log_group_name     = "${var.ecs_cluster_name}-logs" # Example: Generate a log group name dynamicallyww...
  log_stream_prefix  = "ecs"
}

module "s3_bucket" {
  source      = "../modules/s3"
  bucket_name = var.s3_bucket_name
  env              = var.env
}

module "s3_bucket2" {       ########### this bucket is for project files
  source      = "../modules/s3"
  bucket_name = var.s3_bucket2_name
  env              = var.env
}

module "sns_notifications" {
  source     = "../modules/sns"
  topic_name = "${var.topicname}-${var.env}" #"airflow-dag-notifications"
  protocol   = var.protocolname  #"email"
  endpoints   = var.endpointname #"myemail@example.com"
}

module "mwaa" {
  source                           = "../modules/mwaa"
  env                              = var.env
  environment_name                 = var.environment_name
  airflow_version                  = var.airflow_version
  dag_s3_path                      = var.dag_s3_path
  source_bucket_arn                = module.s3_bucket.bucket_arn
  execution_role_arn               = module.mwaa_role.execution_role_arn
  security_group_ids               = [module.mwaa_env_sg.security_group_id]   ## Use the output from the mwaa_env_sg module
  subnet_ids                       = [data.aws_subnet.private_subnet_1a.id, data.aws_subnet.private_subnet_1b.id] #var.subnet_ids   #var.security_group_ids #
  max_workers                      = var.max_workers
  min_workers                      = var.min_workers
  webserver_access_mode            = var.webserver_access_mode

  enable_dag_processing_logs       = var.enable_dag_processing_logs
  dag_processing_log_level         = var.dag_processing_log_level
  enable_scheduler_logs            = var.enable_scheduler_logs
  scheduler_log_level              = var.scheduler_log_level
  enable_task_logs                 = var.enable_task_logs
  task_log_level                   = var.task_log_level
  enable_webserver_logs            = var.enable_webserver_logs
  webserver_log_level              = var.webserver_log_level
  enable_worker_logs               = var.enable_worker_logs
  worker_log_level                 = var.worker_log_level
  weekly_maintenance_window_start  = var.weekly_maintenance_window_start
  tags                             = var.tags
  # set log retention period.
  log_retention_days           = var.log_retention_in_days
}

module "mwaa_env_sg" {
  source      = "../modules/SG"
  env         = var.env
  name        = var.security_group_name
  description = "Security group for MWAA environment"
  vpc_id      = data.aws_vpc.selected.id #"vpc-058457767c544cefd"  passing through the data module

  ingress_rules = {
    allow_https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic from anywhere
    }
    allow_internal = {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks =[data.aws_vpc.selected.cidr_block] #["10.7.224.0/19"] # Allow internal VPC traffic........
    }
  }

  egress_rules = {
    allow_all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic..
    }
  }

  tags = {
    Name = "mwaa-environment-sg-"
  }
}

# Lookup VPC by Name tag.
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["core-vpc"]
  }
}

# Lookup Private Subnet 1A
data "aws_subnet" "private_subnet_1a" {
  filter {
    name   = "tag:Name"
    values = ["PrivateSubnet1A"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Lookup Private Subnet 1B.....
data "aws_subnet" "private_subnet_1b" {
  filter {
    name   = "tag:Name"
    values = ["PrivateSubnet1B"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
