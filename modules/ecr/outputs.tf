output "repository_urls" {
  description = "Map of ECR repository URLs"
  value       = { for env, repo in aws_ecr_repository.this : env => repo.repository_url }
}

output "repositories" {
  description = "Map of ECR repository objects"
  value       = aws_ecr_repository.this
}