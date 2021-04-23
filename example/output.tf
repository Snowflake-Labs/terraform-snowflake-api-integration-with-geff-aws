output "api_integration_name"{
    type        = string
    description = "Name of API integration"
    value       = "${var.prefix}_api_integration"
}

output "api_gateway_invoke_url"{
    type        = list
    description = "List of all invoked url"
    value       = module.aws_api_gateway_deployment.prod.invoke_url
}
