
variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the network."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Provide exactly two distinct Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets, in Availability Zone order."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for private subnets, in Availability Zone order."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDRs."
  }
}

variable "tags" {
  description = "Additional tags applied to network resources."
  type        = map(string)
  default     = {}
}
