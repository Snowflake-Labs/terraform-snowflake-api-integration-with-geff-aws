# GEFF Terraform Module

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
