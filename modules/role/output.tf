output "LAMBDA_ROLE_NAME" {
  value = aws_iam_role.lambda_role.name
}
output "LAMBDA_ROLE_ARN" {
  value = aws_iam_role.lambda_role.arn
}