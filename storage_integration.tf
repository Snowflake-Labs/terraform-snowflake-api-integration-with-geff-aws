module "storage_integration" {
  source  = "Snowflake-Labs/storage-integration-aws/snowflake"
  version = "0.2.11"

  # General
  prefix = var.prefix
  env    = var.env

  # AWS
  data_bucket_arns                 = var.data_bucket_arns
  snowflake_integration_user_roles = var.snowflake_integration_user_roles

  providers = {
    snowflake.storage_integration_role = snowflake.storage_integration_role
    snowsql.storage_integration_role   = snowsql.storage_integration_role
    aws                                = aws
  }
}
