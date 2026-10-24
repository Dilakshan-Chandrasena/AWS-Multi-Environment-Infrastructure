
terraform {
  backend "s3" {
    bucket       = "terraform-aws-infrastructure-state-progress-partners-assessment"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
