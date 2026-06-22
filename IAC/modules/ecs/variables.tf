variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}


variable "family_name" {
  description = "The name of the task definition family"
  type        = string
}

variable "cpu" {
  description = "The value of cpu"
  type        = string
}

variable "memory" {
  description = "The value of memory"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the task execution role"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "container_image" {
  description = "The container image to run"
  type        = string
}

variable "ecs_secrets" {
  description = "List of environment var for ECS task definition"
  type = list(object({
    name      = string
    valueFrom    = string
  }))
  }
variable "env_var" {
  type    = list(object({ name = string, value = string }))
  default = []
}
variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "log_region" {
  description = "The AWS region for the CloudWatch logs"
  type        = string
}

variable "log_stream_prefix" {
  description = "The log stream prefix for the CloudWatch logs"
  type        = string
}