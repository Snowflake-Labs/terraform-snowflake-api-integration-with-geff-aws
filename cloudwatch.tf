resource "aws_cloudwatch_log_group" "geff_lambda_log_group" {
  count             = var.storage_only ? 0 : 1
  name              = "/aws/lambda/${local.geff_prefix}_lambda"
  retention_in_days = var.log_retention_days

  tags = {
    name = "${local.geff_prefix}_lambda"
  }
}

resource "aws_cloudwatch_log_group" "geff_api_gateway_log_group" {
  count = var.storage_only ? 0 : 1

  # We can't change this log group name, as it is fixed by AWS.
  # https://github.com/hashicorp/terraform-provider-aws/issues/8413
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ef_to_lambda[0].id}/${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    name = "${local.geff_prefix}_api_gateway"
  }
}
