################################################################################
# LAMBDA
################################################################################
resource "aws_iam_role" "lambda_role" {
  name = "${var.RESOURCE_PREFIX}-lambda-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}