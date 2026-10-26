
variable "name" {
  description = "Name prefix for monitoring resources."
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "service_name" {
  description = "ECS service name."
  type        = string
}

variable "notification_email" {
  description = "Email address to receive CloudWatch alarm notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.notification_email))
    error_message = "notification_email must be a valid email address."
  }
}

variable "cpu_threshold" {
  description = "CPU utilization alarm threshold percentage."
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "Memory utilization alarm threshold percentage."
  type        = number
  default     = 70
}

variable "desired_task_count" {
  description = "Expected number of running ECS tasks."
  type        = number

  validation {
    condition     = var.desired_task_count >= 1
    error_message = "desired_task_count must be at least 1."
  }
}

variable "create_alarms" {
  description = "Whether to create ECS service monitoring alarms."
  type        = bool
  default     = false
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metric dimensions."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metric dimensions."
  type        = string
}

variable "alb_5xx_threshold" {
  description = "ALB-generated 5xx errors allowed per evaluation period."
  type        = number
  default     = 5
}

variable "target_5xx_threshold" {
  description = "Application-target 5xx errors allowed per evaluation period."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}
