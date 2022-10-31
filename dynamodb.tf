resource "aws_dynamodb_table" "geff_request_locking_table" {
  count        = var.use_custom_dynamodb_table ? 0 : 1
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "batch_id"

  attribute {
    name = "batch_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    name = "${local.geff_prefix}_request_locking_table"
  }
}
