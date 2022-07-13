

resource "aws_lambda_function" "lambda_home" {
  filename         = "${path.module}/code/zip/home.zip"
  function_name    = "${var.RESOURCE_PREFIX}-home"
  role             = "${var.LAMBDA_ROLE_ARN}"
  # handler          = "<file_name>.<function_name_inside_file>"
  handler          = "home.lambda_handler"
  source_code_hash = data.archive_file.lambda_home_archive.output_base64sha256
  runtime          = "python3.8"
  timeout          = 300
}