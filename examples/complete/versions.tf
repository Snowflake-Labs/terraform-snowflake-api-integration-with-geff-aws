terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.0"
    }
  }
}

provider "snowflake" {
  username = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = var.snowflake_role
}
