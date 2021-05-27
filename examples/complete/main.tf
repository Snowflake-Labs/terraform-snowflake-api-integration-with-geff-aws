module "snowflake_api_integration_aws_gateway" {
  source                          = "../../"
  prefix                          = var.prefix
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  env                             = var.env
  snowflake_username              = var.snowflake_username
  snowflake_account               = var.snowflake_account
  snowflake_password              = var.snowflake_password
  snowflake_role                  = var.snowflake_role

  deploy_in_vpc                = var.deploy_in_vpc
  lambda_security_group_vpc_id = var.lambda_security_group_vpc_id
  lambda_security_group_id     = var.lambda_security_group_id
  lambda_subnet_id             = var.lambda_subnet_id
}
