data "archive_file" "lambda_home_archive" {
  type = "zip"
  source_dir = "${path.module}/code/home"
  output_path = "${path.module}/code/zip/home.zip"
}