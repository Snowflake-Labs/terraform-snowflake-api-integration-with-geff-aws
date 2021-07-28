# GEFF Terraform Module

The Generic External Function Framework (GEFF) is extensible Python code which can be called using a [Snowflake External Function](https://docs.snowflake.com/en/sql-reference/external-functions-introduction.html) that allows Snowflake operators to perform generic invocations of Call Drivers (e.g. HTTP, SMTP, XML-RPC) and either return or write responses to generic Destination Drivers (e.g. S3). This empowers them to create new pipelines in Data Infrastructure while using reviewed and standardized RBAC and interaction with Cloud Infrastructure for secrets management.

This terraform module is meant to be used with GEFF as it uses the GEFF package to build the infrastrucuture required to build a Generic External Function.

It automates using terraform the infrastructure pieces of [external function creation with AWS](https://docs.snowflake.com/en/sql-reference/external-functions-creating-aws-ui.html).

It additionally automates the infrastructure pieces of [Snowpipe creation: Option 2](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html).

The Terraform module helps you create Snowflake and AWS resources:

1. **AWS GEFF Lambda** for calling APIs and loading responses
1. **AWS API Gateway** to manage executions of Lambda
1. **AWS IAM Roles** for Snowflake to make invoke API Gateway, access S3 buckets and log to Cloudwatch
1. **AWS SNS Topic** for Snowflake PIPEs to subscribe to to get bucket events
1. **Snowflake API Integration** to expose interface to Snowflake External Functions
1. **Snowflake Storage Integration** to expose interface to ingest data responses

![image](https://user-images.githubusercontent.com/72515998/125895344-dfb554a3-d574-4b4c-a8bb-e89cc9a20e10.png)

## Setup Instructions

```bash
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

## Usage

You can use the `terraform output` to create Snowflake External Functions, Stages, and PIPEs for ingestion, as well as Snowflake External Functions to send data into other systems, (e.g. Tines, PipeDream).
