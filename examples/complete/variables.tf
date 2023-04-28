# Required
variable "snowflake_account" {
  type      = string
  sensitive = true
}

variable "prefix" {
  type        = string
  description = "this will be the prefix used to name the Resources"
}

# Optional
variable "snowflake_api_integration_owner_role" {
  type    = string
  default = "ACCOUNTADMIN"
}

variable "snowflake_storage_integration_owner_role" {
  type    = string
  default = "ACCOUNTADMIN"
}

variable "snowflake_integration_user_roles" {
  type        = list(string)
  default     = []
  description = "List of roles to which GEFF infra will GRANT USAGE ON INTEGRATION perms."
}

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

variable "env" {
  type    = string
  default = "prod"
}

variable "deploy_lambda_in_vpc" {
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
  default     = ["*"]
  description = "GEFF Secrets."
}

variable "geff_dsn" {
  type        = string
  description = "GEFF project Sentry DSN."
  default     = ""
}

variable "sentry_driver_dsn" {
  type        = string
  description = "Snowflake errors project Sentry DSN."
  default     = ""
}

variable "arn_format" {
  type        = string
  description = "ARN format could be aws or aws-us-gov. Defaults to non-gov."
  default     = "aws"
}

variable "create_dynamodb_table" {
  type        = bool
  description = "Boolean for if a DynamoDB table is to be created for batch locking."
  default     = false
}

variable "user_managed_dynamodb_table_name" {
  type        = string
  description = "Name of the user-managed DynamoDB table."
  default     = null
}

variable "dynamodb_table_ttl" {
  type        = number
  description = "TTL for items in the dynamodb table."
  default     = 86400 # 1 day
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
