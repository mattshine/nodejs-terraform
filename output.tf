# Outputs the API endpoint that we can hit
output "api_url" {
    value = aws_api_gateway_deployment.hello_api_deployment.invoke_url
}