module "snowflake_api_integration_aws_gateway" {
  source                          = "../../"
  prefix                          = var.prefix
  snowflake_integration_user      = var.snowflake_integration_user
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  aws_deployment_stage_name       = var.aws_deployment_stage_name
  snowflake_username              = var.snowflake_username
  snowflake_account               = var.snowflake_account
  snowflake_password              = var.snowflake_password
  snowflake_role                  = var.snowflake_role
}
