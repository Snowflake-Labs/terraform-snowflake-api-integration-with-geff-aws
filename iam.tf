# Role  and Policy attachment for the role that the api gateway will assume.
resource "aws_iam_role" "gateway_logger" {
  name = "${var.prefix}_api_gateway_logger"
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


# Role, Role Policy and Policy attachment for the role that the external function will assume.
resource "aws_iam_role" "gateway_caller" {
  name = "${var.prefix}_api_gateway_caller"
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

  depends_on = [
    snowflake_api_integration.api_integration
  ]
}

resource "aws_iam_role_policy" "gateway_caller" {
  name = "${var.prefix}_api_gateway_caller"
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

  depends_on = [
    aws_api_gateway_rest_api.ef_to_lambda
  ]
}

resource "aws_iam_role_policy_attachment" "gateway_caller" {
  role       = aws_iam_role.gateway_caller.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}


# Role, Role Policy for Storage Integration
resource "aws_iam_role" "s3_caller" {
  name = "${var.prefix}_s3_caller"
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

  depends_on = [
    snowflake_storage_integration.geff_storage_integration
  ]
}

resource "aws_iam_role_policy" "s3_caller" {
  name = "${var.prefix}_s3_caller_policy"
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

  depends_on = [
    aws_s3_bucket.geff_bucket
  ]
}
