variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
