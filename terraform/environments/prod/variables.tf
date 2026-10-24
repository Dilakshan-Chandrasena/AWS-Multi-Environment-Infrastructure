variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"

  validation {
    condition     = var.environment == "prod"
    error_message = "The production environment must be named prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR range for the production VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for production."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for production public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for production private subnets."
  type        = list(string)
}

variable "app_port" {
  description = "Port for the application."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of production ECS tasks."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 2
    error_message = "Production must run at least two ECS tasks."
  }
}
