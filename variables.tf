variable "aws_region" {
  description = "The AWS region in which the AWS infrastructure is created."
  default     = "us-west-2"
}

variable "prefix" {
  type        = string
  description = "this will be the prefix used to name the Resources"
  default     = "example"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
}

variable "aws_cloudwatch_metric_namespace" {
  type        = string
  description = "prefix for CloudWatch Metrics that GEFF writes"
  default     = "*"
}

variable "aws_deployment_stage_name" {
  type        = string
  default     = "prod"
  description = "AWS API Gateway deployment stage name"
}

variable "snowflake_account" {
  type        = string
  sensitive   = true
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


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


locals {
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name
}
