
variable "name" {
  description = "Name prefix for ECS resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where tasks will run."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group attached to ECS tasks."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of running tasks."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least 1."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain container logs."
  type        = number
  default     = 7
}

variable "create_service" {
  description = "Whether Terraform should create the ECS service."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to ECS resources."
  type        = map(string)
  default     = {}
}
