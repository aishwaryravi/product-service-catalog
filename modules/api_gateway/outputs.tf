output "api_url" {
  description = "API Gateway endpoint URL"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "rest_api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}