# GEFF Terraform Module

[![Terraform](https://github.com/Snowflake-Labs/terraform-snowflake-aws-geff/actions/workflows/terraform.yml/badge.svg?branch=main)](https://github.com/Snowflake-Labs/terraform-snowflake-aws-geff/actions/workflows/terraform.yml)

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

![image](https://user-images.githubusercontent.com/72515998/125895344-dfb554a3-d574-4b4c-a8bb-e89cc9a20e10.png)

## Setup Instructions

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

```hcl
module "geff" {
  source  = "Snowflake-Labs/aws-geff/snowflake"
  version = "1.x.x"

  prefix                          = var.prefix
  aws_cloudwatch_metric_namespace = var.aws_cloudwatch_metric_namespace
  env                             = var.env
  snowflake_username              = var.snowflake_username
  snowflake_account               = var.snowflake_account
  snowflake_private_key_path      = var.snowflake_private_key_path
  snowflake_role                  = var.snowflake_role

  deploy_in_vpc             = var.deploy_in_vpc
  lambda_security_group_ids = var.lambda_security_group_ids
  lambda_subnet_ids         = var.lambda_subnet_ids
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
CREATE OR REPLACE PIPE new_db.public.pypi_raw_data_pipe
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
