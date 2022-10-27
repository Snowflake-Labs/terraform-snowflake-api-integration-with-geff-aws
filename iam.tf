# This file contains the following IAM resources:
# 1. Role  and Policy attachment for the role that the api gateway will assume.
# 2. Role, Role Policy and Policy attachment for the role that the external function will assume.
# 3. Lambda Assume Role, Assume Role Policy and other Permissions Policy.

# ----------------------------------------------------------------------------
# 1. Role and Policy attachment for the role that the api gateway will assume.
# ----------------------------------------------------------------------------
data "aws_iam_policy_document" "geff_api_gateway_assume_role_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "geff_api_gateway_assume_role" {
  name               = local.api_gw_logger_role_name
  assume_role_policy = data.aws_iam_policy_document.geff_api_gateway_assume_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "gateway_logger_policy_attachment" {
  role       = aws_iam_role.geff_api_gateway_assume_role.id
  policy_arn = "arn:${var.arn_format}:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "api_gateway" {
  cloudwatch_role_arn = aws_iam_role.geff_api_gateway_assume_role.arn
}

# -----------------------------------------------------------------------------------------------
# 2. Role, Role Policy and Policy attachment for the role that the external function will assume.
# -----------------------------------------------------------------------------------------------
resource "aws_iam_role" "gateway_caller" {
  name = local.api_gw_caller_role_name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = snowflake_api_integration.geff_api_integration.api_aws_external_id
          }
        }
        Effect = "Allow"
        Principal = {
          AWS = snowflake_api_integration.geff_api_integration.api_aws_iam_user_arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "gateway_caller_policy" {
  name = "${local.geff_prefix}-invoke-api-gateway-policy"
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

# -----------------------------------------------------------------------
# 3. Lambda Assume Role, Assume Role Policy and other Permissions Policy.
# -----------------------------------------------------------------------
data "aws_iam_policy_document" "geff_lambda_assume_role_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "geff_lambda_assume_role" {
  name               = "${local.geff_prefix}-lambda"
  assume_role_policy = data.aws_iam_policy_document.geff_lambda_assume_role_policy_doc.json
}

data "aws_iam_policy_document" "geff_lambda_policy_doc" {
  # Write logs to cloudwatch
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    resources = [
      "arn:${var.arn_format}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_function_name}:*"
    ]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  # Write metrics to cloudwatch
  statement {
    sid       = "WriteCloudWatchMetrics"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "cloudwatch:PutMetricData",
    ]

    condition {
      test     = "StringLike"
      variable = "cloudwatch:namespace"

      values = [
        var.aws_cloudwatch_metric_namespace
      ]
    }
  }

  statement {
    sid       = "EcrScanImages"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:StartImageScan",
    ]
  }

  # Write to S3
  statement {
    sid       = "WriteToS3"
    effect    = "Allow"
    resources = ["${module.storage_integration.bucket_arn}/*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
  }

  # Invoke a child lambda
  statement {
    sid       = "InvokeLambda"
    effect    = "Allow"
    resources = [aws_lambda_function.geff_lambda.arn]
    actions = [
      "lambda:InvokeFunction"
    ]
  }

  # Access to secrets needed by lambda
  statement {
    sid       = "AccessSecrets"
    effect    = "Allow"
    resources = var.geff_secret_arns
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
  }

  # Access to secrets needed by lambda
  statement {
    sid       = "ListSecrets"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["secretsmanager:ListSecrets"]
  }
}

resource "aws_iam_role_policy" "geff_lambda_policy" {
  name   = "${local.geff_prefix}-lambda-policy"
  role   = aws_iam_role.geff_lambda_assume_role.id
  policy = data.aws_iam_policy_document.geff_lambda_policy_doc.json
}

data "aws_iam_policy" "geff_lambda_vpc_policy" {
  count = var.deploy_lambda_in_vpc ? 1 : 0
  arn   = "arn:${var.arn_format}:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_policy_attachment" "geff_lambda_vpc_policy_attachment" {
  count = var.deploy_lambda_in_vpc ? 1 : 0

  name       = "${local.geff_prefix}-lambda-vpc-policy-attachment"
  roles      = [aws_iam_role.geff_lambda_assume_role.name]
  policy_arn = data.aws_iam_policy.geff_lambda_vpc_policy[0].arn
}

# -----------------------------------------------------------------------------
# 4. Policy for the DynamoDB table to be used as a backend for batch locking
# -----------------------------------------------------------------------------
resource "aws_iam_policy" "dynamodb_table_policy" {
  count = var.request_locking_with_dynamodb ? 1 : 0

  name = "${local.geff_prefix}-dynamodb-table-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.geff_requests_table[0].name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_table_policy_attachment" {
  count = var.request_locking_with_dynamodb ? 1 : 0

  role       = aws_iam_role.geff_lambda_assume_role.name
  policy_arn = aws_iam_policy.dynamodb_table_policy[0].arn
}
