resource "aws_iam_policy" "lambda_basic_permissions_policy" {
  name = "${var.RESOURCE_PREFIX}-lambda-users-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "logs:CreateLogGroup",
        Resource = [
          "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_basic_permissions_policy_attachment" {
  role       = "${var.LAMBDA_ROLE_NAME}"
  policy_arn = "${aws_iam_policy.lambda_basic_permissions_policy.arn}"
}