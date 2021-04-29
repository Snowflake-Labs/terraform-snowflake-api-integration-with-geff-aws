variable "prefix" {
  type        = string
  description = "this will be the prefix used to name the Resources"
  default     = "prasanth"
}

variable "snowflake_integration_user" {
  type        = string
  description = "user who will be calling the API Gateway"
  default     = null
}

variable "aws_cloudwatch_metric_namespace" {
  type        = string
  description = "where EF can write CloudWatch Metrics"
  default     = "*"
}

variable "aws_deployment_stage_name" {
  type        = string
  default     = "prod"
  description = "AWS stage name the Snowflake user will assume to deploy the API Gateway in your account"
}

variable "snowflake_account" {
  type    = string
  default = "KH54840"
}

variable "snowflake_role" {
  type    = string
  default = "ACCOUNTADMIN"
}

variable "snowflake_username" {
  type      = string
  default   = "prasanth"
  sensitive = true
}

variable "snowflake_password" {
  type      = string
  default   = "@kHTN8ihicuwTdQ"
  sensitive = true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name
}
