
variable "aws_region" {
  description = "AWS region for the shared Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
}
