
output "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID attached to ECS tasks."
  value       = aws_security_group.app.id
}
