resource "aws_dynamodb_table" "geff_requests_table" {
  count        = var.request_locking_with_dynamodb ? 1 : 0
  name         = "geff-request-locking"
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
    name = "${local.geff_prefix}_requests_table"
  }
}
