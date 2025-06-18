variable "environment" {
  description = "Environment name (dev)"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for Lambda"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

