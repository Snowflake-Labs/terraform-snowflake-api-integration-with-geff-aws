resource "aws_dynamodb_table" "geff_batch_locking_table" {
  count        = var.create_batch_locking_table ? 1 : 0
  name         = var.batch_locking_table_name != null ? var.batch_locking_table_name : "${local.geff_prefix}_batch_locking_table"
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

resource "aws_dynamodb_table" "geff_rate_limiting_table" {
  count        = var.create_rate_limiting_table ? 1 : 0
  name         = var.rate_limiting_table_name != null ? var.rate_limiting_table_name : "${local.geff_prefix}_rate_limiting_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "url"

  attribute {
    name = "url"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

data "aws_dynamodb_table" "user_managed_batch_locking_table" {
  count = !var.create_batch_locking_table && var.batch_locking_table_name != null ? 1 : 0
  name  = var.batch_locking_table_name
}

data "aws_dynamodb_table" "user_managed_rate_limiting_table" {
  count = !var.create_rate_limiting_table && var.rate_limiting_table_name != null ? 1 : 0
  name  = var.rate_limiting_table_name
}

locals {
  batch_locking_table = (
    var.create_batch_locking_table ? aws_dynamodb_table.geff_batch_locking_table[0] :
    var.batch_locking_table_name != null ? data.aws_dynamodb_table.user_managed_batch_locking_table[0] : null
  )

  rate_limiting_table = (
    var.create_rate_limiting_table ? aws_dynamodb_table.geff_rate_limiting_table[0] :
    var.rate_limiting_table_name != null ? data.aws_dynamodb_table.user_managed_batch_locking_table[0] : null
  )
}
