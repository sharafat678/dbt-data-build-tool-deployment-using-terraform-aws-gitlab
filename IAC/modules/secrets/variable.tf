variable "secret_name" {
  description = "Name of the secret"
  type        = string
}
variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "snowflake_account" {}
variable "snowflake_user" {}
variable "snowflake_password" {}
variable "maximo_user" {}
variable "maximo_password" {}
