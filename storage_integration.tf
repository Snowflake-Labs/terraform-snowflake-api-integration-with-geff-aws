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

resource "snowflake_storage_integration" "geff_storage_integration" {
  name                      = "${local.geff_prefix}_storage_integration"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.geff_bucket.id}/"]
  storage_provider          = "S3"
  storage_aws_role_arn      = "arn:aws:iam::${local.account_id}:role/${var.prefix}_s3_caller"
}
