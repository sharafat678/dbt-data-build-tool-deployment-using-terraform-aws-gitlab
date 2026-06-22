resource "aws_security_group" "this" {
  name        = "${var.name}-${var.env}"
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# resource "aws_security_group_rule" "ingress" {
#   for_each     = var.ingress_rules
#   type         = "ingress"
#   from_port    = each.value.from_port
#   to_port      = each.value.to_port
#   protocol     = each.value.protocol
#   cidr_blocks  = each.value.cidr_blocks
#   security_group_id = aws_security_group.this.id
# }
resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.this.id

  # Use `cidr_blocks` or `source_security_group_id` based on the configuration
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

resource "aws_security_group_rule" "egress" {
  for_each     = var.egress_rules
  type         = "egress"
  from_port    = each.value.from_port
  to_port      = each.value.to_port
  protocol     = each.value.protocol
  cidr_blocks  = each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
}
