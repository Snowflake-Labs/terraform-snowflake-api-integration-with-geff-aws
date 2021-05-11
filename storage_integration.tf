resource "aws_s3_bucket" "geff_bucket" {
  bucket = "${var.prefix}-geff-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "geff_data_folder" {
  bucket = aws_s3_bucket.geff_bucket.id
  key    = "data/"
}

resource "aws_s3_bucket_object" "geff_meta_folder" {
  bucket = aws_s3_bucket.geff_bucket.id
  key    = "meta/"
}

resource "snowflake_storage_integration" "geff_storage_integration" {
  name                      = "${var.prefix}-geff-storage-integration"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.geff_bucket.id}/"]
  storage_provider          = "S3"
  storage_aws_role_arn      = "arn:aws:iam::${local.account_id}:role/${var.prefix}-s3-caller"
}

resource "aws_iam_role" "s3_caller" {
  name = "${var.prefix}-s3-caller"
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
  name = "${var.prefix}-s3-caller"
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
