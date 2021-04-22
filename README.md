# Generic Exteranal Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such:

- **GEFF Lambda** for calling API's and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![API-Module Architecture  (2)](https://user-images.githubusercontent.com/42752788/115786776-1e9ce800-a376-11eb-9a1b-ee12658ad3ed.png)
