terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.24.0"
    }
  }
}

provider "snowflake" {
  username = var.snowflake_username
  account  = var.snowflake_account
  password = var.snowflake_password
  role     = var.snowflake_role
}

provider "aws" {
  region = "us-west-2"
}