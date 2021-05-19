resource "snowflake_storage_integration" "geff_storage_integration" {
  name                      = "${local.geff_prefix}_storage_integration"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${aws_s3_bucket.geff_bucket.id}/"]
  storage_provider          = "S3"
  storage_aws_role_arn      = "arn:aws:iam::${local.account_id}:role/${local.s3_caller_role_name}"
}
