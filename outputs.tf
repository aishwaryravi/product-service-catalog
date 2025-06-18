output "dev_api_url" {
  description = "Dev environment API Gateway URL"
  value       = module.api_gateway.api_url  # Changed from module.lambda to module.api_gateway
}

output "qa_lb_url" {
  description = "QA environment load balancer URL"
  value       = module.qa_environment.lb_url
}

output "prod_lb_url" {
  description = "Prod environment load balancer URL"
  value       = module.prod_environment.lb_url
}

output "ecr_repositories" {
  description = "Map of ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "dynamodb_tables" {
  description = "Map of DynamoDB table names"
  value       = module.dynamodb.table_names
}