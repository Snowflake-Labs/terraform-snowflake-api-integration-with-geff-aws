data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-code"
  output_path = "${path.module}/lambda-code.zip"
  excludes = [
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
  ]
}

resource "aws_lambda_function" "geff_lambda" {
  function_name    = local.lambda_function_name
  role             = aws_iam_role.geff_lambda_assume_role.arn
  handler          = "lambda_function.lambda_handler"
  memory_size      = "4096" # 4 GB
  runtime          = "python3.8"
  timeout          = "900" # 15 mins
  publish          = null
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  depends_on = [
    aws_s3_bucket.geff_bucket,
    aws_s3_bucket_object.geff_data_folder,
    aws_s3_bucket_object.geff_meta_folder,
    aws_cloudwatch_log_group.geff_lambda_log_group,
  ]
}

resource "aws_lambda_permission" "api_gateway" {
  function_name = aws_lambda_function.geff_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*"
}
