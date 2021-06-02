# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![API-Module Architecture  (4)](https://user-images.githubusercontent.com/77613909/120427846-4e390a00-c390-11eb-930d-c7c40370f73e.png)
