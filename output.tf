output "api_integration_name" {
  description = "Name of API integration"
  value       = "${var.prefix}_api_integration"
}

output "api_gateway_invoke_url" {
  description = "List of all invoked url"
  value       = aws_api_gateway_deployment.geff.invoke_url
}

output "storage_integration_name" {
  description = "Name of Storage integration"
  value       = "${var.prefix}-geff-storage-integration"
}
