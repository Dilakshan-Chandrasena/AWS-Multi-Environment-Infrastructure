
output "vpc_id" {
  description = "Production VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Production public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Production private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "Production NAT Gateway IDs by Availability Zone."
  value       = module.network.nat_gateway_ids
}

output "alb_dns_name" {
  description = "DNS name of the production Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "URL of the production ECR repository."
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the production ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the production ECS service."
  value       = "${var.environment}-platform-service"
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = module.iam.execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS application task role."
  value       = module.iam.task_role_arn
}
