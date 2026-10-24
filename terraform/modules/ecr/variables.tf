
variable "name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "tags" {
  description = "Tags to apply to ECR resources."
  type        = map(string)
  default     = {}
}

variable "max_image_count" {
  description = "Maximum number of images to retain."
  type        = number
  default     = 10

  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}
