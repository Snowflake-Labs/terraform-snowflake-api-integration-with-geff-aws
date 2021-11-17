locals {
  source_code_repo_dir_path = "geff"
  runtime                   = "python3.8"
}


resource "aws_lambda_function" "geff_lambda" {
  count         = var.storage_only ? 0 : 1
  function_name = local.lambda_function_name
  role          = aws_iam_role.geff_lambda_assume_role[0].arn

  memory_size = "4096" # 4 GB

  # Here snowflake (client) timeout is 10 mins, lambda (server) timeout is 3s
  timeout = "3" # Default

  image_uri    = local.lambda_image_repo_version
  package_type = "Image"

  vpc_config {
    security_group_ids = var.deploy_lambda_in_vpc ? var.lambda_security_group_ids : []
    subnet_ids         = var.deploy_lambda_in_vpc ? var.lambda_subnet_ids : []
  }

  depends_on = [
    aws_s3_bucket.geff_bucket,
    aws_s3_bucket_object.geff_meta_folder,
    aws_cloudwatch_log_group.geff_lambda_log_group[0],
  ]
}


resource "aws_lambda_permission" "api_gateway" {
  count = var.storage_only ? 0 : 1

  function_name = aws_lambda_function.geff_lambda[0].function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.ef_to_lambda[0].execution_arn}/*/*"
}
