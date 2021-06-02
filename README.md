# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

API-Module Architecture  (2).png![API-Module Architecture  (2)](https://user-images.githubusercontent.com/77609784/120494878-d263af80-c3d9-11eb-824f-0e7faae17f48.png)


