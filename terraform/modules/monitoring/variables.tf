
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

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}
