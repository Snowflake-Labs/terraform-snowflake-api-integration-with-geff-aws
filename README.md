# Generic Exteranal Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such:

- **GEFF Lambda** for calling API's and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![API-Module Architecture  (4)](https://user-images.githubusercontent.com/42752788/115787563-40e33580-a377-11eb-8ac8-9c3b6bfa8496.png)
