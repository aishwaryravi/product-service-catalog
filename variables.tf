variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for ECS deployments"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS deployments"
  type        = list(string)
}

variable "allowed_ips" {
  description = "IPs allowed to access production environment"
  type        = list(string)
  default     = []
}

variable "github_repo_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to trigger pipeline"
  type        = string
  default     = "master"
}

variable "github_token" {
  description = "GitHub OAuth token"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "github_webhook_token" {
  description = "Secret token for GitHub webhook"
  type        = string
  sensitive   = true
}