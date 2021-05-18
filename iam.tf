# This file contains the following IAM resources:
# 1. Role  and Policy attachment for the role that the api gateway will assume.
# 2. Role, Role Policy and Policy attachment for the role that the external function will assume.
# 3. Role, Role Policy for Storage Integration
# 4. Lambda Assume Role, Assume Role Policy and other Permissions Policy.

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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
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
  name = "${var.prefix}_invoke_api_gateway_policy"
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

# ---------------------------------------------
# 3. Role, Role Policy for Storage Integration.
# ---------------------------------------------
resource "aws_iam_role" "s3_caller" {
  name = local.s3_caller_role_name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : snowflake_storage_integration.geff_storage_integration.storage_aws_iam_user_arn
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : snowflake_storage_integration.geff_storage_integration.storage_aws_external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_caller" {
  name = "${var.prefix}_rw_to_s3_bucket_policy"
  role = aws_iam_role.s3_caller.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : "${aws_s3_bucket.geff_bucket.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : aws_s3_bucket.geff_bucket.arn,
        "Condition" : {
          "StringLike" : {
            "s3:prefix" : [
              "*"
            ]
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------
# 4. Lambda Assume Role, Assume Role Policy and other Permissions Policy.
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
  name               = "${local.geff_prefix}_lambda"
  assume_role_policy = data.aws_iam_policy_document.geff_lambda_assume_role_policy_doc.json
}

data "aws_iam_policy_document" "geff_lambda_policy_doc" {
  # Write logs to cloudwatch
  statement {
    sid       = "WriteCloudWatchLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_function_name}:*"]

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

  # Write to S3
  statement {
    sid       = "WriteToS3"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.geff_bucket.arn}/*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
  }

  # Decrypt with KMS
  statement {
    sid       = "DecryptWithKMS"
    effect    = "Allow"
    resources = [aws_kms_key.prod.arn]
    actions = [
      "kms:Decrypt"
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
}

resource "aws_iam_role_policy" "geff_lambda_policy" {
  name   = "${local.geff_prefix}_lambda_policy"
  role   = aws_iam_role.geff_lambda_assume_role.id
  policy = data.aws_iam_policy_document.geff_lambda_policy_doc.json
}
