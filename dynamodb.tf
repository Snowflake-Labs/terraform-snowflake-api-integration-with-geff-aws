resource "aws_dynamodb_table" "geff_batch_locking_table" {
  count        = var.create_dynamodb_table ? 1 : 0
  name         = var.user_managed_dynamodb_table_name != null ? var.user_managed_dynamodb_table_name : "${local.geff_prefix}_batch_locking_table" 
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "batch_id"

  attribute {
    name = "batch_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

data "aws_dynamodb_table" "user_managed_table" {
  count = var.user_managed_dynamodb_table_name != null && !var.create_dynamodb_table ? 1 : 0
  name  = var.user_managed_dynamodb_table_name
}

locals {
  dynamodb_table_name = var.user_managed_dynamodb_table_name != null ? (var.create_dynamodb_table ? aws_dynamodb_table.geff_batch_locking_table[0].name : data.aws_dynamodb_table.user_managed_table[0].name) : (var.create_dynamodb_table ?  aws_dynamodb_table.geff_batch_locking_table[0].name : null)
  dynamodb_table_arn = var.user_managed_dynamodb_table_name != null ? (var.create_dynamodb_table ? aws_dynamodb_table.geff_batch_locking_table[0].arn : data.aws_dynamodb_table.user_managed_table[0].arn) : (var.create_dynamodb_table ?  aws_dynamodb_table.geff_batch_locking_table[0].arn : null)
}
