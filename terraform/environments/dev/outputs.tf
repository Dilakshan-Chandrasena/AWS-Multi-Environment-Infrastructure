
output "vpc_id" {
  description = "Development VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Development public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Development private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "Development NAT Gateway IDs by Availability Zone."
  value       = module.network.nat_gateway_ids
}
