
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "progress-partners-assessment"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
