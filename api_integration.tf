resource "snowflake_api_integration" "api_integration" {
  name                 = "${var.prefix}_api_integration"
  enabled              = true
  api_provider         = "aws_api_gateway"
  api_allowed_prefixes = [aws_api_gateway_deployment.geff.invoke_url]
  api_aws_role_arn     = "arn:aws:iam::${local.account_id}:role/${var.prefix}-api-gateway-caller"
}

