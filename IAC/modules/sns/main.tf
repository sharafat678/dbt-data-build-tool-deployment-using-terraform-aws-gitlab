resource "aws_sns_topic" "this" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "this" {
  for_each  = toset(var.endpoints)   # create one subscription per endpoint  
  topic_arn = aws_sns_topic.this.arn
  protocol  = var.protocol       # e.g., "email", "sqs", "lambda"
  endpoint  = each.value   # e.g., "example@example.com"
  
}
