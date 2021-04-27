output "api_integration_name"{
    # type        = string
    description = "Name of API integration"
    value       = "${var.prefix}_api_integration"
}

output "api_gateway_invoke_url"{
    # type        = list
    description = "List of all invoked url"
    value       = module.snowflake_api_integration_aws_gateway.api_gateway_invoke_url
}