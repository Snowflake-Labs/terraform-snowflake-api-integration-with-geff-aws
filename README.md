# Generic External Function Framework (GEFF)

Terraform module to create a snowflake API integrations and dependent resources such as:

- **GEFF Lambda** for calling APIs and loading responses
- **API Gateway** to manage executions of Lambda
- **IAM Role** for Snowflake to make invoke API Gateway
- **API Integration** to expose interface to Snowflake External Functions
- **Storage Integration** to expose interface to ingest data responses

![image](https://user-images.githubusercontent.com/72515998/120515966-7fdfbe80-c3ec-11eb-9d90-0bb9de895705.png)
