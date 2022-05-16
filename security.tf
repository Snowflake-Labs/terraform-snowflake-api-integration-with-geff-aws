resource "aws_security_group" "geff_lambda_sg" {
  count = length(var.lambda_security_group_ids) == 0 ? 1 : 0

  name        = "${local.geff_prefix}-lambda-sg"
  description = "Create security group for lambda if not provided."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "geff_lambda_sg_egress_rule" {
  count = length(var.lambda_security_group_ids) == 0 ? 1 : 0

  type        = "egress"
  to_port     = 0
  from_port   = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.geff_lambda_sg.0.id
}

resource "aws_security_group_rule" "geff_lambda_sg_egress_allow_all_traffic_intra_vpc_rule" {
  count = length(var.allowed_sg_ids) == 0 ? 1 : 0

  type                     = "egress"
  to_port                  = 0
  from_port                = 0
  protocol                 = "-1"
  source_security_group_id = var.allowed_sg_ids[count.index]

  security_group_id = aws_security_group.geff_lambda_sg.0.id
}

