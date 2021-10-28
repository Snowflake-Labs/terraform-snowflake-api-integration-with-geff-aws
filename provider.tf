# The following variables are set:
# export SNOWFLAKE_USER="snowflake_username"
# export SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_key.p8"
# export SNOWFLAKE_PRIVATE_KEY_PASSPHRASE="snowflake_passphrase"

provider "snowflake" {
  account = var.snowflake_account
  role    = var.snowflake_role
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      environment = var.env
    }
  }
}

