resource "aws_dynamodb_table" "vectors_ikeda" {
  name         = "vectors-ikeda"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "vectors-ikeda"
  }
}
