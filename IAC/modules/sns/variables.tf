variable "topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "protocol" {
  description = "The protocol to use (e.g., email, sqs, lambda, https)"
  type        = string
}

variable "endpoints" {
  description = "The endpoint for the subscription (email, SQS ARN, Lambda ARN, etc.)"
  type        = list(string)
}
