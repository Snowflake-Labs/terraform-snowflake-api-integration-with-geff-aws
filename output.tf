output "api_gateway_invoke_url" {
  description = "This is the inferred API Gateway invoke URL which we use as allowed prefixes."
  value       = aws_api_gateway_deployment.geff_api_gw_deployment.invoke_url
}

output "api_integration_name" {
  description = "Name of API integration"
  value       = snowflake_api_integration.geff_api_integration.name
}

output "storage_integration_name" {
  description = "Name of Storage integration"
  value       = snowflake_storage_integration.geff_storage_integration.name
}

output "bucket_url" {
  description = "GEFF S3 Bucket URL"
  value       = "s3://${aws_s3_bucket.geff_bucket.id}/"
}

output "sns_topic_arn" {
  description = "GEFF S3 SNS Topic to use while creating the Snowflake PIPE."
  value       = aws_sns_topic.geff_bucket_sns.arn
}

