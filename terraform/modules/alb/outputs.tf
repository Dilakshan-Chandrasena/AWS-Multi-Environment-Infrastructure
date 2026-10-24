
output "alb_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name used to access the load balancer."
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID associated with the ALB."
  value       = aws_lb.this.zone_id
}
