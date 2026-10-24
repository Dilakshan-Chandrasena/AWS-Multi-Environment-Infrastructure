
variable "name" {
  description = "Name prefix for ECS IAM roles."
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources."
  type        = map(string)
  default     = {}
}
