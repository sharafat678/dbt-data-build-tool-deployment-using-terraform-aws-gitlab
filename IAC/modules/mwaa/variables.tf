variable "environment_name" {
  description = "The name of the MWAA environment"
  type        = string
}
variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "airflow_version" {
  description = "The version of Apache Airflow to use"
  type        = string
}

variable "dag_s3_path" {
  description = "The relative path to the DAGs folder in the source S3 bucket"
  type        = string
}

variable "source_bucket_arn" {
  description = "The ARN of the source S3 bucket for DAGs"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the IAM execution role for MWAA"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs for the MWAA environment"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The subnet IDs for the MWAA environment"
  type        = list(string)
}

variable "max_workers" {
  description = "The maximum number of workers"
  type        = number
  default     = 10
}

variable "min_workers" {
  description = "The minimum number of workers"
  type        = number
  default     = 1
}

variable "webserver_access_mode" {
  description = "The webserver access mode (PUBLIC_ONLY or PRIVATE_ONLY)"
  type        = string
  default     = "PUBLIC_ONLY"
}

variable "enable_dag_processing_logs" {
  description = "Enable DAG processing logs"
  type        = bool
  default     = true
}

variable "dag_processing_log_level" {
  description = "Log level for DAG processing logs"
  type        = string
  default     = "INFO"
}

variable "enable_scheduler_logs" {
  description = "Enable scheduler logs"
  type        = bool
  default     = true
}

variable "scheduler_log_level" {
  description = "Log level for scheduler logs"
  type        = string
  default     = "INFO"
}

variable "enable_task_logs" {
  description = "Enable task logs"
  type        = bool
  default     = true
}

variable "task_log_level" {
  description = "Log level for task logs"
  type        = string
  default     = "INFO"
}

variable "enable_webserver_logs" {
  description = "Enable webserver logs"
  type        = bool
  default     = true
}

variable "webserver_log_level" {
  description = "Log level for webserver logs"
  type        = string
  default     = "INFO"
}

variable "enable_worker_logs" {
  description = "Enable worker logs"
  type        = bool
  default     = true
}

variable "worker_log_level" {
  description = "Log level for worker logs"
  type        = string
  default     = "INFO"
}

variable "weekly_maintenance_window_start" {
  description = "The weekly maintenance window start time in UTC (e.g., 'SUN:03:00')"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the environment"
  type        = map(string)
}


variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}