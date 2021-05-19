resource "aws_kms_key" "prod" {
  description = "key used to encrypt passwords"

  policy = jsonencode(
    {
      Id = "key-default-1"
      Statement = [
        {
          Action = "kms:*"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${local.account_id}:root"
          }
          Resource = "*"
          Sid      = "Enable IAM User Permissions"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {}
}
