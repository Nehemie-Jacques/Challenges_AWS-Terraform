resource "aws_dynamodb_table" "crud_table" {
  name         = "crud_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "CRUD Table"
  }
}