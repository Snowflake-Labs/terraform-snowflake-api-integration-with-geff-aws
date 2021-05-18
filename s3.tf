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

<<<<<<< HEAD
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
=======
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

>>>>>>> 45d5e08026e15b9a58592957bbd21420561cb619
