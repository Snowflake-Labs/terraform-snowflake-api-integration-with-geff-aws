resource "snowflake_api_integration" "geff_api_integration" {
  name                 = "${local.geff_prefix}_api_integration"
  enabled              = true
  api_provider         = "aws_api_gateway"
  api_allowed_prefixes = [local.inferred_api_gw_invoke_url]
  api_aws_role_arn     = "arn:aws:iam::${local.account_id}:role/${var.prefix}_api_gateway_caller"
}
