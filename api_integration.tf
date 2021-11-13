resource "snowflake_api_integration" "geff_api_integration" {
  name                 = "${upper(replace(local.geff_prefix, "-", "_"))}_API_INTEGRATION"
  enabled              = true
  api_provider         = "aws_api_gateway"
  api_allowed_prefixes = [local.inferred_api_gw_invoke_url]
  api_aws_role_arn     = "arn:aws:iam::${local.account_id}:role/${local.api_gw_caller_role_name}"
}

resource "snowflake_integration_grant" "geff_api_integration_grant" {
  integration_name = snowflake_api_integration.geff_api_integration.name

  privilege = "USAGE"
  roles     = var.snowflake_integration_user_roles

  with_grant_option = false
}
