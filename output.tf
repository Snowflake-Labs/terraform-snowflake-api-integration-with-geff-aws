output "api_integration_name" {
  description = "Name of API integration"
  value       = "${var.prefix}_api_integration"
}

output "api_gateway_invoke_url" {
  description = "List of all invoked url"
  value       = aws_api_gateway_deployment.geff_api_gw_deployment.invoke_url
}

output "storage_integration_name" {
  description = "Name of Storage integration"
  value       = "${var.prefix}-geff-storage-integration"
}

output "bucket_url" {
  description = "GEFF S3 Bucket URL"
  value       = "s3://${aws_s3_bucket.geff_bucket.id}/${aws_s3_bucket_object.geff_data_folder.id}"
}

output "allowed_prefixes" {
  description = "This is the inferred API Gateway invoke URL which we use as allowed prefixes."
  value       = local.inferred_api_gw_invoke_url
}
