resource "aws_s3_bucket" "geff_bucket" {
  bucket = "${var.prefix}-geff-bucket" # Only hiphens + lower alphanumeric are allowed for bucket name
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

resource "aws_sns_topic" "geff_bucket_sns" {
  name = "${local.geff_prefix}_geff_bucket_sns"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "sns1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:*:*:${local.geff_prefix}_geff_bucket_sns",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_s3_bucket.geff_bucket.arn}"
        }
      }
    },
    {
      "Sid": "sns2",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${snowflake_storage_integration.geff_storage_integration.storage_aws_iam_user_arn}"
        ]
      },
      "Action": "sns:Subscribe",
      "Resource": "arn:aws:sns:*:*:${local.geff_prefix}_geff_bucket_sns",
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.geff_bucket.id

  topic {
    topic_arn = aws_sns_topic.geff_bucket_sns.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
