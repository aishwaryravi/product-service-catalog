output "lb_url" {
  description = "Load balancer URL"
  value       = "http://${aws_lb.this.dns_name}"
}

output "lb_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.this.arn
}