variable "environment" {
  description = "Environment name (qa or prod)"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

variable "ecs_exec_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
}

variable "enable_waf" {
  description = "Whether to enable WAF protection"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "List of allowed IPs for production"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = null # Will use environment-based defaults
}

variable "memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = null # Will use environment-based defaults
}