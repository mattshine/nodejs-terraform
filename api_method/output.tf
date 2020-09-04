# We pass these outputs to our root main.tf
output "http_method" {
  value = aws_api_gateway_integration_response.response_method_integration.http_method
}
