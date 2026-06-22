resource "aws_iam_role" "role" {
  name               = "${var.role_name}-${var.env}"
  assume_role_policy = jsonencode(var.assume_role_policy)
}

data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = var.policy_statements
    content {
      effect    = statement.value["Effect"]
      actions   = statement.value["Action"]
      resources = statement.value["Resource"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.policy_name}-${var.env}"
  description = var.policy_description
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

# resource "aws_iam_role" "my_role" {
#   name               = var.role_name
#   assume_role_policy = jsonencode(var.assume_role_policy)
# }

# resource "aws_iam_policy" "my_policy" {
#   name        = "${var.role_name}-policy"
#   description = var.policy_description
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = var.policy_statements
#   })
# }

# resource "aws_iam_role_policy_attachment" "execution_role_attachment" {
#   role       = aws_iam_role.my_role.name
#   policy_arn = aws_iam_policy.my_policy.arn
# }
