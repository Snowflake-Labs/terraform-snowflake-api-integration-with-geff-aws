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

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "sns:Subscribe"
      ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration.geff_storage_integration.storage_aws_iam_user_arn]
    }

    resources = [
      "arn:aws:sns:us-west-2:${local.account_id}:${var.prefix}-sns-topic"
      ]

    sid = "__default_statement_ID"
  }
  statement {
    actions = [
      "SNS:Publish"
      ]

    condition {
      test     = "ArnLike"
      variable = "SNS:SourceArn"

      values = [
        aws_s3_bucket.geff_bucket.arn,
      ]
    }

    effect = "Allow"

    principals {
      type        = "services"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:sns:us-west-2:${local.account_id}:${aws_s3_bucket.geff_bucket.id}"
      ]

    sid = "1"
  }
}

resource "aws_sns_topic" "user_updates" {
  name         = "${var.prefix}-sns-topic"
  policy       = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sqs_queue" "sqs_queue" {
  name     = "${var.prefix}-sqs-queue"
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue.arn
}

