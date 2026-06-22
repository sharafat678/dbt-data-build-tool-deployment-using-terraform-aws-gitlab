variable "role_name" {
  type        = string
  description = "Name of the IAM role to create."
}
variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "policy_name" {
  type        = string
  description = "Name of the IAM policy."
}

variable "policy_description" {
  type        = string
  description = "Description of the IAM policy."
}

variable "assume_role_policy" {
  type        = any
  description = "Assume role policy document for the IAM role."
}

variable "policy_statements" {
  type        = list(object({
    Effect   = string
    Action   = list(string)
    Resource  = optional(list(string))  # Mark Resource as optional
    NotResource = optional(list(string))     # Add support for NotResource
    Condition = optional(map(any))     # Keep other attributes optional
  }))
  description = "List of policy statements to include in the IAM policy."
}
variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

# variable "role_name" {
#   description = "Name of the task execution role"
#   type        = string
# }

# variable "assume_role_policy" {
#   description = "IAM trust policy that allows the role to be assumed"
#   type        = any
# }

# variable "policy_name" {
#   description = "Name of the IAM policy"
#   type        = string
# }

# variable "policy_description" {
#   description = "Description of the IAM policy"
#   type        = string
#   default     = "Managed policy created by Terraform"
# }

# # variable "policy_statements" {
# #   description = "List of IAM policy statements"
# #   type        = list(map(string))
# # }
# variable "policy_statements" {
#   description = "The policy statements for the IAM role"
#   type = list(object({
#     Effect   = string
#     Action   = list(string)
#     Resource = list(string)
#   }))
# }