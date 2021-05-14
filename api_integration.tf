locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}

locals {
  inferred_api_gw_invoke_url = "https://${aws_api_gateway_rest_api.ef_to_lambda.id}.execute-api.${local.aws_region}.amazonaws.com/"
}

resource "snowflake_api_integration" "api_integration" {
  name                 = "${var.prefix}_api_integration"
  enabled              = true
  api_provider         = "aws_api_gateway"
  api_allowed_prefixes = [local.inferred_api_gw_invoke_url]
  api_aws_role_arn     = "arn:aws:iam::${local.account_id}:role/${var.prefix}_api_gateway_caller"

  depends_on = [
    aws_api_gateway_rest_api.ef_to_lambda
  ]
}
