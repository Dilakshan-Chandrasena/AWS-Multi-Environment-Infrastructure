
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR range of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered by the configured Availability Zones."
  value       = [for az in var.availability_zones : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, ordered by the configured Availability Zones."
  value       = [for az in var.availability_zones : aws_subnet.private[az].id]
}

output "public_subnet_ids_by_az" {
  description = "Public subnet IDs keyed by Availability Zone."
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "private_subnet_ids_by_az" {
  description = "Private subnet IDs keyed by Availability Zone."
  value       = { for az, subnet in aws_subnet.private : az => subnet.id }
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs keyed by Availability Zone."
  value       = { for az, nat in aws_nat_gateway.this : az => nat.id }
}
