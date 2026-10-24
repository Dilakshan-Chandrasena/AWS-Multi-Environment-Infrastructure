
variable "name" {
  description = "Name prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and targets will operate."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  type        = string
}

variable "app_port" {
  description = "Port on which the application listens."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used to check application health."
  type        = string
  default     = "/health"
}


variable "certificate_arn" {
  description = "ACM certificate ARN required for HTTPS."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.certificate_arn)) > 0
    error_message = "A valid ACM certificate ARN must be provided."
  }
}

variable "tags" {
  description = "Tags to apply to ALB resources."
  type        = map(string)
  default     = {}
}
