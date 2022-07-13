output "LAMBDA_HOME_NAME" {
  value = aws_lambda_function.lambda_home.function_name
}
output "LAMBDA_HOME_ARN" {
  value = aws_lambda_function.lambda_home.arn
}
output "LAMBDA_HOME_INVOKE_ARN" {
  value = aws_lambda_function.lambda_home.invoke_arn
}