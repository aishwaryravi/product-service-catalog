variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function to invoke"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}