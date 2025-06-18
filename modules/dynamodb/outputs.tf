output "table_names" {
  value = merge(
    { for k, v in aws_dynamodb_table.dev : "dev" => v.name if length(aws_dynamodb_table.dev) > 0 },
    { for k, v in aws_dynamodb_table.non_dev : k => v.name }
  )
}

output "table_arns" {
  value = merge(
    { for k, v in aws_dynamodb_table.dev : "dev" => v.arn if length(aws_dynamodb_table.dev) > 0 },
    { for k, v in aws_dynamodb_table.non_dev : k => v.arn }
  )
}