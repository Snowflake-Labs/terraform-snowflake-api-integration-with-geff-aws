resource "aws_api_gateway_rest_api" "ef_to_lambda" {
  name = "${local.geff_prefix}_api_gateway"

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "time_sleep" "wait_20_seconds" {
  depends_on      = [aws_iam_role.gateway_caller]
  create_duration = "20s"
}

resource "aws_api_gateway_rest_api_policy" "ef_to_lambda" {
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:sts::${local.account_id}:assumed-role/${local.api_gw_caller_role_name}/snowflake"
        }
        Action   = "execute-api:Invoke"
        Resource = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*/*"
      }
    ]
  })

  depends_on = [
    time_sleep.wait_20_seconds,
    aws_api_gateway_rest_api.ef_to_lambda
  ]
}

resource "aws_api_gateway_resource" "https" {
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id
  parent_id   = aws_api_gateway_rest_api.ef_to_lambda.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "https_any_method" {
  rest_api_id    = aws_api_gateway_rest_api.ef_to_lambda.id
  resource_id    = aws_api_gateway_resource.https.id
  http_method    = "ANY"
  authorization  = "AWS_IAM"
  request_models = {}

  request_parameters = {
    "method.request.header.sf-custom-base-url"      = false
    "method.request.header.sf-custom-url"           = false
    "method.request.header.sf-custom-method"        = false
    "method.request.header.sf-custom-headers"       = false
    "method.request.header.sf-custom-params"        = false
    "method.request.header.sf-custom-data"          = false
    "method.request.header.sf-custom-json"          = false
    "method.request.header.sf-custom-timeout"       = false
    "method.request.header.sf-custom-auth"          = false
    "method.request.header.sf-custom-response-type" = false
    "method.request.header.sf-custom-verbose"       = false
  }
}

resource "aws_api_gateway_integration" "https_to_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.ef_to_lambda.id
  resource_id             = aws_api_gateway_resource.https.id
  http_method             = aws_api_gateway_method.https_any_method.http_method
  integration_http_method = "POST" # Lambda integration only uses POST
  type                    = "AWS_PROXY"

  uri                  = aws_lambda_function.geff_lambda.invoke_arn
  cache_key_parameters = null
  request_parameters   = {}
  request_templates    = {}
}

resource "aws_api_gateway_deployment" "geff_api_gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ef_to_lambda))
  }

  lifecycle {
    create_before_destroy = true
  }

  # We ensure that the deployment of the gateway happens only after:
  # 1. The rest api policy is applied and hence won't require a redeployment
  # 2. The API integration has been 
  depends_on = [
    aws_api_gateway_integration.https_to_lambda,
    aws_api_gateway_rest_api_policy.ef_to_lambda
  ]
}

resource "aws_api_gateway_stage" "geff_api_gw_stage" {
  deployment_id = aws_api_gateway_deployment.geff_api_gw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ef_to_lambda.id
  stage_name    = var.env

  depends_on = [aws_cloudwatch_log_group.geff_api_gateway_log_group]
}

resource "aws_api_gateway_method_settings" "enable_logging" {
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id
  stage_name  = aws_api_gateway_stage.geff_api_gw_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level          = "INFO"
    metrics_enabled        = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }

  depends_on = [aws_api_gateway_account.api_gateway]
}
