# Generic Exteranal Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such:

- **GEFF Lambda** for calling API's and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![API-Module Architecture  (3)](https://user-images.githubusercontent.com/42752788/115787206-ae429680-a376-11eb-886f-dad86612aa6e.png)
