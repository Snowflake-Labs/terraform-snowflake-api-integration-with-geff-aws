locals {
  source_code_repo_dir_path = "geff"
  runtime                   = "python3.8"
}


resource "aws_lambda_function" "geff_lambda" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.geff_lambda_assume_role.arn

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
    module.gsif.geff_bucket,
    module.gsif.geff_meta_folder,
    aws_cloudwatch_log_group.geff_lambda_log_group,
  ]
}


resource "aws_lambda_permission" "api_gateway" {
  function_name = aws_lambda_function.geff_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.ef_to_lambda.execution_arn}/*/*"
}
