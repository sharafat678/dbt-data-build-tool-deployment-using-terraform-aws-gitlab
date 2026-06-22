output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.my-bucket.arn
}

output "bucket_name" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.my-bucket.bucket
}

