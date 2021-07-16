# Generic External Function Framework (GEFF) Infrastructure

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![image](https://user-images.githubusercontent.com/72515998/125895344-dfb554a3-d574-4b4c-a8bb-e89cc9a20e10.png)


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
