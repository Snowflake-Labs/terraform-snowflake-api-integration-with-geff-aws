variable api_integration_name{
    type        = string
    description = "Name of API integration"
    value       = "${var.prefix}_api_integration"
}
variable api_gateway_invoke_url{
    type        = list
    description = "List of all invoked url"
    value       = aws_api_gateway_deployment.prod.invoke_url
}
