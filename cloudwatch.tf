resource "aws_cloudwatch_log_group" "geff_lambda_log_group" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    name = "${local.geff_prefix}_lambda"
  }
}

resource "aws_cloudwatch_log_group" "geff_api_gateway_log_group" {
  # We can't change this log group name, as it is fixed by AWS.
  # https://github.com/hashicorp/terraform-provider-aws/issues/8413
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ef_to_lambda.id}/${var.env}"
  retention_in_days = var.log_retention_days

  tags = {
    name = "${local.geff_prefix}_api_gateway"
  }
}

resource "aws_cloudwatch_log_metric_filter" "response_size_filter" {
  name           = "${local.geff_prefix}-response-size-filter"
  pattern        = "[..., got=\"Got\", the=\"the\", response=\"response\", body=\"body\", with=\"with\", length= \"length:\", num_of_bytes_in_response]"
  log_group_name = aws_cloudwatch_log_group.geff_lambda_log_group.name

  metric_transformation {
    name      = "Response Size"
    namespace = "${local.geff_prefix}-metrics"
    value     = "$num_of_bytes_in_response"
    unit      = "Bytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "request_size_filter" {
  name           = "${local.geff_prefix}-response-size-filter"
  pattern        = "[..., request=\"Request\", sent=\"sent\", with=\"with\", length= \"length:\", num_of_bytes_in_request]"
  log_group_name = aws_cloudwatch_log_group.geff_lambda_log_group.name

  metric_transformation {
    name      = "Request Size"
    namespace = "${local.geff_prefix}-metrics"
    value     = "$num_of_bytes_in_request"
    unit      = "Bytes"
  }
}


resource "aws_cloudwatch_log_metric_filter" "invocation_count_filter" {
  name           = "${local.geff_prefix}-invocation-count-filter"
  pattern        = "\"Invocation:\""
  log_group_name = aws_cloudwatch_log_group.geff_lambda_log_group.name

  metric_transformation {
    name      = "Invocation Count"
    namespace = "${local.geff_prefix}-metrics"
    value     = "1"
  }
}
