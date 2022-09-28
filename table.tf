resource "aws_dynamodb_table" "geff_requests_table" {
  name           = "geff-requests"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "batch_id"

  attribute {
    name = "batch_id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    name = "${local.geff_prefix}_requests_table"
  }
}
