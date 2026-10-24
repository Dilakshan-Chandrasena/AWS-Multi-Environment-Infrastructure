
module "network" {
  source = "../../modules/network"

  name               = "${var.environment}-platform"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    Environment = var.environment
  }
}




module "ecr" {
  source = "../../modules/ecr"

  name = "progress-partners-assessment-${var.environment}"

  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}
