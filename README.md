# Generic External Function Framework (GEFF) Infrastructure

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![image](https://user-images.githubusercontent.com/72515998/120515966-7fdfbe80-c3ec-11eb-9d90-0bb9de895705.png)

## Prerequisites

Keep username and password ready for a snowflake user that has access to create api and storage integrations

## Setup Instructions

```bash
# Navigate to the examples/complete dir
cd examples/complete

# Copy the sample tfvars file
mv example.tfvars.sample geff.tfvars

# Modify the values in the tfvars, input appropriate credentials and values per your environment.

# Run the terraform
terraform init
terraform plan -var-file=geff.tfvars -out=geff.plan
terraform apply "geff.plan"
```
