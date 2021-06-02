# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![image](https://user-images.githubusercontent.com/72515998/120512482-098d8d00-c3e9-11eb-861a-f5e2c53be5c9.png)
