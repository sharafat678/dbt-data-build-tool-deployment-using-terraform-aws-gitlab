variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}