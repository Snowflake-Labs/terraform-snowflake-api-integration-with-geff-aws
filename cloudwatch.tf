resource "aws_iam_policy" "cloudwatch_write" {
  name = "${var.prefix}_cloudwatch_etup_and_write"
  path = "/service-role/"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowWritingLogs",
          Effect = "Allow",
          Action = [
            "logs:PutLogEvents",
            "logs:CreateLogStream",
            "logs:CreateLogGroup"
          ],
          Resource = "arn:aws:logs:*:*:*"
        },
        {
          Effect   = "Allow",
          Action   = "cloudwatch:PutMetricData",
          Resource = "*"
          Condition = {
            StringLike = {
              "cloudwatch:namespace" = var.aws_cloudwatch_metric_namespace
            }
          }
        },
      ]
    }
  )
}
