module "geff" {
  source                          = "../../"
  prefix                          = var.prefix
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  env                             = var.env
  snowflake_username              = var.snowflake_username
  snowflake_account               = var.snowflake_account
  snowflake_password              = var.snowflake_password
  snowflake_role                  = var.snowflake_role

  deploy_in_vpc             = var.deploy_in_vpc
  lambda_security_group_ids = var.lambda_security_group_ids
  lambda_subnet_ids         = var.lambda_subnet_ids
}
