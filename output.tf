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
  value       = module.gsif.storage_integration_name
}

output "bucket_url" {
  description = "GEFF S3 Bucket URL"
  value       = module.gsif.bucket_url
}

output "sns_topic_arn" {
  description = "GEFF S3 SNS Topic to use while creating the Snowflake PIPE."
  value       = module.gsif.sns_topic_arn
}

