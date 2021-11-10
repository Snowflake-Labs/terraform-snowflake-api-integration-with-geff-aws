module "geff" {
  source = "../../"

  # General
  prefix = var.prefix
  env    = var.env

  # Snowflake
  snowflake_account = var.snowflake_account
  snowflake_role    = var.snowflake_integration_owner_role

  # AWS
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  aws_region                      = var.aws_region
  deploy_lambda_in_vpc            = var.deploy_lambda_in_vpc
  lambda_security_group_ids       = var.lambda_security_group_ids
  lambda_subnet_ids               = var.lambda_subnet_ids
}
