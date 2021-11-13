resource "snowflake_storage_integration" "geff_storage_integration" {
  name    = "${upper(replace(local.geff_prefix, "-", "_"))}_STORAGE_INTEGRATION"
  type    = "EXTERNAL_STAGE"
  enabled = true
  storage_allowed_locations = concat(
    ["s3://${aws_s3_bucket.geff_bucket.id}/"],
    [
      for bucket_arn in var.data_bucket_arns :
      "s3://${element(split(":::", bucket_arn), 1)}/"
    ]
  )
  storage_provider     = "S3"
  storage_aws_role_arn = "arn:aws:iam::${local.account_id}:role/${local.s3_reader_role_name}"
}
