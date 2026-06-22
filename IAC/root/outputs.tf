output "cluster_id" {
  value = module.ecs.cluster_id
}

output "repository_url" {
  value = module.ecr.repository_url
}

output "repository_name" {
  value = module.ecr.repository_name
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_name" {
  description = "The Name of the S3 bucket"
  value       = module.s3_bucket.bucket_name
}

output "bucket2_name" {
  description = "The Name of the S3 bucket"
  value       = module.s3_bucket2.bucket_name
}

output "bucket2_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_bucket2.bucket_arn
}

output "mwaa_env_security_group_id" {
  description = "ID of the security group"
  value       = module.mwaa_env_sg.security_group_id
}

output "webserver_url_1" {
  value = module.mwaa.webserver_url
}

output "full_task_definition_name" {
  value = "${module.ecs.task_definition_name}:${module.ecs.task_definition_revision}"
}

output "subnet_ids" {
  value = module.mwaa.subnet_ids
  description = "List of subnet IDs for the MWAA environment."
}

output "container_name" {
  value = var.ecs_container_name
  description = "The name of the container from ECS task definition"
}


# output "efs_id" {
#   value = module.ecs.efs_id
#   description = "value of efs id"
# }

# output "efs_ip" {
#   value = module.ecs.mount_ips
#   description = "value of efs id"
# }

output "cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "secret_arn" {
  description = "ARN of the created secret"
  value       = module.snowflake_secret.secret_arn
}


output "sns_topic_arn" {
  value = module.sns_notifications.sns_topic_arn
}