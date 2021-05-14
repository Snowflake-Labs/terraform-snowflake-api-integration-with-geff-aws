output "api_integration_name" {
  description = "Name of API integration"
  value       = "${var.prefix}_api_integration"
}

output "api_gateway_invoke_url" {
  description = "List of all invoked url"
  value       = module.snowflake_api_integration_aws_gateway.api_gateway_invoke_url
}

output "storage_integration_name" {
  description = "Name of Storage integration"
  value       = "${var.prefix}-geff-storage-integration"
}

output "bucket_url" {
  description = "GEFF S3 Bucket URL"
  value       = module.snowflake_api_integration_aws_gateway.bucket_url
}

output "allowed_prefixes" {
  description = "This is the inferred API Gateway invoke URL which we use as allowed prefixes."
  value       = module.snowflake_api_integration_aws_gateway.allowed_prefixes
}
