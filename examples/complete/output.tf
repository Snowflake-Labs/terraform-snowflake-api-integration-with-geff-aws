output "api_gateway_invoke_url" {
  description = "List of all invoked url"
  value       = module.geff.api_gateway_invoke_url
}

output "allowed_prefixes" {
  description = "This is the inferred API Gateway invoke URL which we use as allowed prefixes."
  value       = module.geff.allowed_prefixes
}

output "api_integration_name" {
  description = "Name of API integration"
  value       = module.geff.api_integration_name
}

output "storage_integration_name" {
  description = "Name of Storage integration"
  value       = module.geff.storage_integration_name
}

output "bucket_url" {
  description = "GEFF S3 Bucket URL"
  value       = module.geff.bucket_url
}

output "s3_sns_topic_arn" {
  description = "GEFF S3 SNS Topic to use while creating the Snowflake PIPE."
  value       = module.geff.s3_sns_topic_arn
}
