# As mentioned here from the tf snowflake provider:
# https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs#keypair-authentication-passhrase
# The following variables you need to set up in the environment:
# export SNOWFLAKE_USER="snowflake_username"
# export SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_key.p8"
# export SNOWFLAKE_PRIVATE_KEY_PASSPHRASE="snowflake_passphrase"

# As mentioned here from the tf aws provider:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
# The following variables you need to set up in the environment:
# export AWS_ACCESS_KEY_ID="anaccesskey"
# export AWS_SECRET_ACCESS_KEY="asecretkey"
# export AWS_DEFAULT_REGION="us-west-2"

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

