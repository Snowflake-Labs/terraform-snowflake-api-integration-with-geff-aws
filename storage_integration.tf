module "storage_integration" {
  source  = "Snowflake-Labs/storage-integration/snowflake"
  version = "1.0.0"

  snowflake_account                = var.snowflake_account
  snowflake_integration_user_roles = var.snowflake_integration_user_roles

  providers = {
    snowflake.storage_integration = snowflake.storage_integration
  }
}
