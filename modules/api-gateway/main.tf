data "template_file" api_swagger{
  template = "${file("${path.root}/modules/api-gateway/swagger-file/swagger.yml")}"
  vars = {
    LAMBDA_HOME_INVOKE_ARN = var.LAMBDA_HOME_INVOKE_ARN
  }
}


resource "aws_api_gateway_rest_api" "api_gateway" {
  description  = "${var.RESOURCE_PREFIX} Rest API Gateway"
  name = "${var.ENV}-${var.RESOURCE_PREFIX}-api_rest_api"
  body = data.template_file.api_swagger.rendered
  disable_execute_api_endpoint = false
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api_policy.api_policy,
    aws_lambda_permission.lambda_permission
  ]
  
  variables = {
    "deployed_at" = "${timestamp()}"
  }
}

resource "aws_api_gateway_stage" "api_stages" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.ENV
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": [
          "${aws_api_gateway_rest_api.api_gateway.execution_arn}",
          "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*"
        ]
      }
    ]
  }
  EOF
}


################################################################################
# Permissions - Lambda(s)
################################################################################
resource "aws_lambda_permission" "lambda_permission" {
  function_name = var.LAMBDA_HOME_NAME
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
  depends_on = [
    aws_api_gateway_rest_api.api_gateway
  ]
}
