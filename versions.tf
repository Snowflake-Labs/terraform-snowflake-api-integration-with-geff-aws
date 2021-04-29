terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.0"
    }
  }
}

