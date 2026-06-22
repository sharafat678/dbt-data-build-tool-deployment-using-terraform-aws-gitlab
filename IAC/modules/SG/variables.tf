variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    source_security_group_id = optional(string) 
  }))
  default = {}
}

variable "egress_rules" {
  description = "Egress rules for the security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {}
}
