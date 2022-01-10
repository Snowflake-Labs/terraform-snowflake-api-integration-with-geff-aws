terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71.0"

      configuration_aliases = [aws.region_specific]
    }

    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = ">= 0.25.32"
    }
  }
}
