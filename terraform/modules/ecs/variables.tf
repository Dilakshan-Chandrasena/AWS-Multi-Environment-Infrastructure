
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

variable "execution_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "task_role_arn" {
  description = "Application task role ARN."
  type        = string
}

variable "image_uri" {
  description = "Container image URI, including its tag."
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

variable "cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "aws_region" {
  description = "AWS region used by the container log configuration."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain container logs."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to ECS resources."
  type        = map(string)
  default     = {}
}
