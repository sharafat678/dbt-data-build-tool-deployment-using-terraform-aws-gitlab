resource "aws_secretsmanager_secret" "this" {
  name = "${var.secret_name}-${var.env}"
}

resource "aws_secretsmanager_secret_version" "snowflake" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    SNOWFLAKE_ACCOUNT  = var.snowflake_account
    SNOWFLAKE_USER     = var.snowflake_user
    SNOWFLAKE_PASSWORD = var.snowflake_password
    MAXIMO_USER      = var.maximo_user
    MAXIMO_password  = var.maximo_password
  })
}