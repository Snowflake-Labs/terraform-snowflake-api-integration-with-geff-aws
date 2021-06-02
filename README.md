# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

API-Module Architecture  (1).png![API-Module Architecture  (1)](https://user-images.githubusercontent.com/77609784/120495536-6d5c8980-c3da-11eb-8742-94ea5ccb6380.png)



