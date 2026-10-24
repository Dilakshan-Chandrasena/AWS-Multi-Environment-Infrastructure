
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

variable "tags" {
  description = "Tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}
