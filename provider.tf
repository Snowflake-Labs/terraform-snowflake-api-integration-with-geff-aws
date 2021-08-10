provider "snowflake" {
  username         = var.snowflake_username
  account          = var.snowflake_account
  password         = var.snowflake_password
  role             = var.snowflake_role
  private_key_path = var.snowflake_private_key_path
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.env
    }
  }
}

