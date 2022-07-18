resource "snowflake_api_integration" "geff_api_integration" {
  provider = snowflake.api_integration_role

  name                 = "${upper(replace(var.prefix, "-", "_"))}_API_INTEGRATION"
  enabled              = true
  api_provider         = length(regexall(".*gov.*", local.aws_region)) > 0 ? "aws_gov_api_gateway" : "aws_api_gateway"
  api_allowed_prefixes = [local.inferred_api_gw_invoke_url]
  api_aws_role_arn     = "arn:${var.arn_format}:iam::${local.account_id}:role/${local.api_gw_caller_role_name}"
}

resource "snowflake_integration_grant" "geff_api_integration_grant" {
  provider = snowflake.api_integration_role

  integration_name  = snowflake_api_integration.geff_api_integration.name
  privilege         = "USAGE"
  roles             = var.snowflake_integration_user_roles
  with_grant_option = false
}
