/*
  logging API Gateway logging is set up per-region
*/
resource "aws_iam_role" "gateway_logger" {
  name = "${var.prefix}-api-gateway-logger"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gateway_logger" {
  role       = aws_iam_role.gateway_logger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "api_gateway" {
  cloudwatch_role_arn = aws_iam_role.gateway_logger.arn
}

/*
  rest is API Gateway specific to External Functions
*/
resource "aws_iam_role" "gateway_caller" {
  name = "${var.prefix}-api-gateway-caller"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = snowflake_api_integration.api_integration.api_aws_external_id
          }
        }
        Effect = "Allow"
        Principal = {
          AWS = snowflake_api_integration.api_integration.api_aws_iam_user_arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "gateway_caller" {
  name = "${var.prefix}-api-gateway-caller"
  role = aws_iam_role.gateway_caller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "execute-api:Invoke"
        Resource = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gateway_caller" {
  role       = aws_iam_role.gateway_caller.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_api_gateway_rest_api" "ef_to_lambda" {
  name = "${var.prefix}-seceng-external-functions"
  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_rest_api_policy" "ef_to_lambda" {
  depends_on = [
    aws_api_gateway_rest_api.ef_to_lambda,
    aws_api_gateway_method_settings.enable_logging,
    aws_iam_role_policy_attachment.gateway_caller,
    aws_iam_role_policy.gateway_caller,
  ]
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:sts::${local.account_id}:assumed-role/${var.prefix}-api-gateway-caller/snowflake"
        }
        Action   = "execute-api:Invoke"
        Resource = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*/*"
      },
    ]
  })
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
  
  uri                     = aws_lambda_function.geff_lambda.invoke_arn
  cache_key_parameters    = null
  request_parameters      = {}
  request_templates       = {}
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "api_gw_${aws_api_gateway_rest_api.ef_to_lambda.id}/${var.env}"
  retention_in_days = var.log_retention_days
}

resource "aws_api_gateway_deployment" "geff" {
  depends_on = [
    aws_api_gateway_integration.https_to_lambda
  ]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ef_to_lambda))
  }

  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "geff" {
  deployment_id = aws_api_gateway_deployment.geff.id
  rest_api_id   = aws_api_gateway_rest_api.ef_to_lambda.id
  stage_name    = var.env
}

resource "aws_api_gateway_method_settings" "enable_logging" {
  depends_on  = [aws_api_gateway_account.api_gateway]
  rest_api_id = aws_api_gateway_rest_api.ef_to_lambda.id
  stage_name  = aws_api_gateway_stage.geff.stage_name
  method_path = "*/*"
  settings {
    logging_level          = "INFO"
    metrics_enabled        = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}
