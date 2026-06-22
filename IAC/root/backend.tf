terraform {
  backend "s3" {
    bucket         = "my-terraform-backend"
    key            = "dbt-infra-s3/terraform.tfstate"
    region         = "cn-northwest-1"
    encrypt        = true
    use_lockfile   = true # This enables native locking Now with Terraform 1.10 and above, AWS S3 itself supports locking, no need for DynamoDB table.
  }
}
