resource "aws_security_group" "geff_lambda_sg" {
  name        = "${local.geff_prefix}-lambda-sg"
  description = "Create security group for lambda if not provided."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "geff_lambda_sg_egress_rule" {
  type        = "egress"
  to_port     = 0
  from_port   = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.geff_lambda_sg.id
}
