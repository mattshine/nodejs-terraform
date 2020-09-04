# We pass these outputs to our root main.tf
output "name" {
  value = aws_lambda_function.lambda.function_name
}
