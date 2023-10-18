resource "aws_dynamodb_table" "items" {
  name         = "items"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "N"
  }

  hash_key = "id"

  lifecycle {
    prevent_destroy = true
  }
}
