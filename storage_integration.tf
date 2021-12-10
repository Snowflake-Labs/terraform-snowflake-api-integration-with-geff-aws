


module "gsif" {
  source                           = "git::https://github.com/Snowflake-Labs/terraform-snowflake-storage-integration.git"
  snowflake_account                = var.snowflake_account
  snowflake_integration_user_roles = var.snowflake_integration_user_roles

}
