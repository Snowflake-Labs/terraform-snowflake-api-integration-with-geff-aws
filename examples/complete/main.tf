module "geff" {
  source = "../../"

  # General
  prefix = var.prefix
  env    = var.env

  # AWS
  arn_format                      = var.arn_format
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  aws_region                      = var.aws_region

  deploy_lambda_in_vpc      = var.deploy_lambda_in_vpc
  lambda_security_group_ids = var.lambda_security_group_ids
  lambda_subnet_ids         = var.lambda_subnet_ids
  vpc_id                    = var.vpc_id

  geff_image_version               = var.geff_image_version
  data_bucket_arns                 = var.data_bucket_arns
  snowflake_integration_user_roles = var.snowflake_integration_user_roles
  geff_secret_arns                 = var.geff_secret_arns

  create_dynamodb_table            = var.create_dynamodb_table
  user_managed_dynamodb_table_name = var.user_managed_dynamodb_table_name

  create_dynamodb_table            = var.create_dynamodb_table
  user_managed_dynamodb_table_name = var.user_managed_dynamodb_table_name

  providers = {
    snowflake.api_integration_role     = snowflake.api_integration_role
    snowflake.storage_integration_role = snowflake.storage_integration_role
    aws                                = aws
  }
}
