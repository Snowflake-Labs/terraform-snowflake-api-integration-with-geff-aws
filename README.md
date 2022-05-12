# _API Integration with GEFF Backend_

[![Terraform](https://github.com/Snowflake-Labs/terraform-snowflake-api-integration-with-geff/actions/workflows/terraform.yml/badge.svg)](https://github.com/Snowflake-Labs/terraform-snowflake-api-integration-with-geff/actions/workflows/terraform.yml)

The Generic External Function Framework (GEFF) is a generic backend for [Snowflake External Functions](https://docs.snowflake.com/en/sql-reference/external-functions-introduction.html) which allows Snowflake operators to perform generic invocations of Call Drivers (e.g. HTTP, SMTP, XML-RPC) and either return to Snowflake or write call responses using Destination Drivers (e.g. S3). This empowers them to create new pipelines in Snowflake's Data Cloud using a standardized RBAC structure and interactions with Cloud Infrastructure for authentication credentials and other secrets management.

This project uses Terraform to build the AWS and Snowflake resources required to run a Python Lambda version of GEFF for arbitrary interactions with remote services using Snowflake and the (optional) writing of responses to an S3 bucket.

It helps automate creation of:

- [API Integrations](https://docs.snowflake.com/en/sql-reference/sql/create-api-integration.html) for [External Functions](https://docs.snowflake.com/en/sql-reference/sql/create-external-function.html) in Snowflake and [supporting AWS infra](https://docs.snowflake.com/en/sql-reference/external-functions-creating-aws-ui.html).
- [Storage Integration](https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration.html) for [Snowpipes](https://docs.snowflake.com/en/sql-reference/sql/create-pipe.html) and [supporting AWS infra](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html).

Specifically, it helps you create the following AWS and Snowflake resources:

1. **AWS GEFF Lambda** to implement and exec the Call and Destination drivers
1. **AWS API Gateway** to connect calls using a Snowflake API Integration to Lambda
1. **AWS IAM Roles** for Snowflake to invoke API Gateway and access S3 bucket, and for Labmda and API Gateway to log to CloudWatch
1. **AWS SNS Topic** for Snowpipe to subscribe to CreateObject events
1. **Snowflake API Integration** to power External Functions
1. **Snowflake Storage Integration** to power Snowpipes

![image](https://user-images.githubusercontent.com/72515998/152404944-54cc8d0f-ed71-49b3-9084-19c4626eb489.png)

## Setup Instructions

#### Build and Upload the GEFF docker image to ECR

```bash
# Clone repo
git clone git@github.com:Snowflake-Labs/geff.git

# Run ecr.sh, NOTE: This steps needs Docker Desktop to be running.
./ecr.sh 123556660 us-west-2
```

#### Clone and run from source examples

```bash
# git clone https://github.com/Snowflake-Labs/terraform-snowflake-aws-geff.git

# Navigate to the examples/complete dir
cd examples/complete

# Copy the sample tfvars file
cp example.tfvars.sample geff.tfvars

# Modify the values in the tfvars, input appropriate credentials and values per your environment.

# Run the terraform
terraform init
terraform plan -var-file=geff.tfvars -out=geff.plan
terraform apply "geff.plan"
```

#### Use in terraform code

```terraform
module "api_integration_with_geff" {
  source = "Snowflake-Labs/api-integration-with-geff-aws/snowflake"

  # Required
  prefix = var.prefix
  env    = var.env

  # Snowflake
  snowflake_integration_user_roles = var.snowflake_integration_user_roles

  # AWS
  aws_region = local.aws_region

  # Other config items
  geff_image_version = var.geff_image_version
  data_bucket_arns   = var.data_bucket_arns
  geff_secret_arns   = local.snowalert_secret_arns

  providers = {
    snowflake.api_integration_role     = snowflake.api_integration_role
    snowflake.storage_integration_role = snowflake.storage_integration_role
    aws                           = aws
  }
}
```

## Usage in Snowflake

You can use the `terraform output` to create Snowflake External Functions, Stages, and PIPEs for ingestion, as well as Snowflake External Functions to send data into other systems, (e.g. Tines, PipeDream).

Let's assume this is the terraform output:

```text
api_gateway_invoke_url = "https://a1b2c3d4.execute-api.ap-east-2.amazonaws.com/"
api_integration_name = "test_geff_api_integration"
bucket_url = "s3://test-geff-bucket/"
sns_topic_arn = "arn:aws:sns:ap-east-2:0123456789:test_geff_bucket_sns_x1y2z3"
storage_integration_name = "test_geff_storage_integration"
```

### Create External Function

```sql
CREATE OR REPLACE SECURE EXTERNAL FUNCTION snowflake_db.snowflake_schema.pypi_packages_s3()
RETURNS VARIANT
RETURNS NULL ON NULL INPUT
VOLATILE
COMMENT='https://warehouse.pypa.io/api-reference/xml-rpc.html'
API_INTEGRATION="test_geff_api_integration"
HEADERS=(
    'url'='https://pypi.org/pypi'
    'method-name'='list_packages'
    'destination-uri' = 's3://test-geff-bucket/pypi_packages/'
)
AS 'https://x1y2z3.execute-api.ap-east-2.amazonaws.com/prod_stage/xml-rpc';
```

### Create Stage

```sql
CREATE OR REPLACE STAGE snowflake_db.snowflake_schema.test_geff_bucket_stage
STORAGE_INTEGRATION="test_geff_storage_integration"
URL='s3://test-geff-bucket/pypi_packages'
FILE_FORMAT=(
  TYPE='JSON'
)
;
```

### Create Snowpipe

```sql
CREATE OR REPLACE PIPE snowflake_db.snowflake_schema.pypi_raw_data_pipe
    AUTO_INGEST=TRUE
    aws_sns_topic = 'arn:aws:sns:ap-east-2:0123456789:pattest_geff_bucket_sns_x1y2z3'
AS
COPY INTO new_db.public.pypi_packages_raw(
    name,
    recorded_at
)
FROM (
    SELECT
        $1::STRING,
        CURRENT_TIMESTAMP
    FROM @pattest_geff_bucket/pypi_packages
);
```
