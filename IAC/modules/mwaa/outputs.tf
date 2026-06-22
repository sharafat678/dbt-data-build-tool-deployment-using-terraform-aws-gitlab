output "environment_name" {
  value = aws_mwaa_environment.this.name
}

output "webserver_url" {
  value = aws_mwaa_environment.this.webserver_url
}

output "subnet_ids" {
  value = var.subnet_ids
  description = "List of subnet IDs for the MWAA environment."
}