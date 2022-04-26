# Required Variables
variable "prefix" {
  type        = string
  description = "This will be the prefix used to name the Resources."
}

# Optional Variables
variable "aws_region" {
  description = "The AWS region in which the AWS infrastructure is created."
  type        = string
  default     = "us-west-2"
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
  description = "Dev/Prod/Staging or any other custom environment name."
  default     = "dev"
}

variable "snowflake_integration_user_roles" {
  type        = list(string)
  default     = []
  description = "List of roles to which GEFF infra will GRANT USAGE ON INTEGRATION perms."
}

variable "deploy_lambda_in_vpc" {
  type        = bool
  description = "The security group VPC ID for the lambda function."
  default     = false
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

variable "vpc_id" {
  type        = string
  description = "The VPC ID for creating the lambda and security group ID."
  default     = null
}

variable "geff_image_version" {
  type        = string
  description = "Version of the GEFF docker image."
  default     = "latest"
}

variable "data_bucket_arns" {
  type        = list(string)
  default     = []
  description = "List of Bucket ARNs for the s3_reader role to read from."
}

variable "geff_secret_arns" {
  type        = list(string)
  default     = []
  description = "GEFF Secrets."
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}

locals {
  lambda_image_repo = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/geff"
}

locals {
  lambda_image_repo_version = "${local.lambda_image_repo}:${var.geff_image_version}"
}

locals {
  inferred_api_gw_invoke_url = "https://${aws_api_gateway_rest_api.ef_to_lambda.id}.execute-api.${local.aws_region}.amazonaws.com/"
  geff_prefix                = "${var.prefix}-geff"
}

locals {
  lambda_function_name    = "${local.geff_prefix}-lambda"
  api_gw_caller_role_name = "${local.geff_prefix}-api-gateway-caller"
  api_gw_logger_role_name = "${local.geff_prefix}-api-gateway-logger"
}
