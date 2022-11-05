terraform {
  required_version = "~> 1.3.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }

    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.40.0"

      configuration_aliases = [
        snowflake.api_integration_role,
        snowflake.storage_integration_role,
      ]
    }
  }
}
