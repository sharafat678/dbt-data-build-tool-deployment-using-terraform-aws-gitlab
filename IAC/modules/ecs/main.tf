resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}-${var.env}"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.family_name}-${var.env}"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn #aws_iam_role.task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      secrets   = var.ecs_secrets
      environment = var.env_var
      logConfiguration = {
        logDriver = "awslogs"
  options = {
              awslogs-group         = "${var.log_group_name}-${var.env}"
              awslogs-region        = var.log_region
              awslogs-stream-prefix = "${var.log_stream_prefix}-${var.env}"
            }
      }
    }
  ])
}
  

# resource "aws_iam_role" "task_role" {
#   name = "ecs-task-role-${var.env}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy" "s3_access" {
#   name = "ecs-task-s3-access-${var.env}"
#   role = aws_iam_role.task_role.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#                 "s3:GetObject",
#                 "s3:ListBucket"
#         ]
#         Effect   = "Allow"
#         Resource = [
#         module.s3_bucket2.bucket_arn,          # Bucket ARN
#       "${module.s3_bucket2.bucket_arn}/*"    # Bucket ARN with objects....
#           ]
#       }
#     ]
#   })
# }



# resource "aws_ecs_task_definition" "this" {
#   family                   = "${var.family_name}-${var.env}"
#   execution_role_arn       = var.execution_role_arn
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = var.cpu #
#   memory                   = var.memory #
#   network_mode             = "awsvpc"
#   container_definitions    = jsonencode([
#     {
#       name      = var.container_name
#       image     = var.container_image
#       essential = true
#       secrets   = var.ecs_secrets
#       environment = var.env_var
#       mountPoints = [
#         {
#           containerPath = "/mnt/shared-volume"
#           sourceVolume  = "shared-volume"
#           readOnly      = false
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = var.log_group_name
#           "awslogs-region"        = var.log_region
#           "awslogs-stream-prefix" = var.log_stream_prefix
#         }
#       }
#     }
#   ])

# }

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.log_group_name}-${var.env}"
  retention_in_days = 7
}
