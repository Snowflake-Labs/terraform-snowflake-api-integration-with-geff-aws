variable "aws_region" {
  description = "The AWS region in which the AWS infrastructure is created."
  default     = "us-west-2"
}

variable "prefix" {
  type        = string
  description = <<EOT
    This will be the prefix used to name the Resources.
    WARNING: Enter a short prefix in order to prevent name length related restrictions
  EOT
  default     = "example"
}

variable "aws_cloudwatch_metric_namespace" {
  type        = string
  description = "prefix for CloudWatch Metrics that GEFF writes"
  default     = "*"
}

variable "log_retention_days" {
  description = "Log retention period in days."
  default     = 0 # Forever
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Dev/Prod/Staging or any other custom environment name."
}

variable "snowflake_account" {
  type      = string
  sensitive = true
}

variable "snowflake_role" {
  type    = string
  default = "ACCOUNTADMIN"
}

variable "snowflake_username" {
  type      = string
  sensitive = true
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}

variable "deploy_in_vpc" {
  type        = bool
  default     = false
  description = "The security group VPC ID for the lambda function."
}

variable "lambda_security_group_ids" {
  type        = list(string)
  default     = []
  description = "The security group IDs for the lambda function."
}

variable "lambda_subnet_ids" {
  type        = list(string)
  default     = []
  description = "The subnet IDs for the lambda function."
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}

locals {
  inferred_api_gw_invoke_url = "https://${aws_api_gateway_rest_api.ef_to_lambda.id}.execute-api.${local.aws_region}.amazonaws.com/"
  geff_prefix                = "${var.prefix}_geff"
}

locals {
  lambda_function_name    = "${local.geff_prefix}_lambda"
  api_gw_caller_role_name = "${local.geff_prefix}_api_gateway_caller"
  api_gw_logger_role_name = "${local.geff_prefix}_api_gateway_logger"
  s3_caller_role_name     = "${local.geff_prefix}_s3_caller"
  s3_sns_policy_name      = "${local.geff_prefix}_s3_sns_topic_policy"
  s3_sns_topic_name       = "${local.geff_prefix}_bucket_sns"
}
