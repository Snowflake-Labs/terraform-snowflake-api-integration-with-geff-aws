module "geff" {
  source                          = "../../"
  prefix                          = var.prefix
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  env                             = var.env
  snowflake_account               = var.snowflake_account
  snowflake_role                  = var.snowflake_role

  deploy_lambda_in_vpc      = var.deploy_lambda_in_vpc
  lambda_security_group_ids = var.lambda_security_group_ids
  lambda_subnet_ids         = var.lambda_subnet_ids
}
