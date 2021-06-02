# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

API-Module Architecture  (1).png![API-Module Architecture  (1)](https://user-images.githubusercontent.com/77609784/120495118-08089880-c3da-11eb-99cf-148eb3641251.png)



