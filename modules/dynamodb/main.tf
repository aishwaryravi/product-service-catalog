resource "aws_dynamodb_table" "dev" {
  count = contains(keys(var.tables), "dev") ? 1 : 0

  name         = "product-catalog-dev"
  billing_mode = var.tables["dev"].billing_mode
  hash_key     = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "non_dev" {
  for_each = { for k, v in var.tables : k => v if k != "dev" }

  name         = "product-catalog-${each.key}"
  billing_mode = each.value.billing_mode
  hash_key     = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity

  lifecycle {
    prevent_destroy = true
  }
}