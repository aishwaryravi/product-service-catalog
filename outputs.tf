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
output "generated_webhook_token" {
  value       = random_password.webhook_token.result
  sensitive   = true
  description = "Generated GitHub webhook token (save this securely)"
}

output "webhook_url" {
  description = "The URL of the webhook"
  value       = aws_codepipeline_webhook.github_webhook.url
  sensitive   = true
}

output "webhook_secret" {
  value       = random_password.webhook_token.result
  description = "The secret token for GitHub webhook"
  sensitive   = true
}