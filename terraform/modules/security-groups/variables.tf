
variable "name" {
  description = "Name prefix for security groups."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created."
  type        = string
}

variable "app_port" {
  description = "Port on which the application listens."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Tags to apply to security groups."
  type        = map(string)
  default     = {}
}
