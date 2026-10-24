module "network" {
  source = "../../modules/network"

  name               = "${var.environment}-platform"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}

module "security_groups" {
  source = "../../modules/security-groups"

  name     = "${var.environment}-platform"
  vpc_id   = module.network.vpc_id
  app_port = var.app_port

  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}

module "alb" {
  source = "../../modules/alb"

  name                  = "${var.environment}-platform"
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  certificate_arn       = "arn:aws:acm:us-east-1:796480644368:certificate/b34166e0-a111-4a41-a6f4-4e11b50d1a69"
  app_port              = var.app_port
  health_check_path     = "/health"

  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}

module "iam" {
  source = "../../modules/iam"

  name = "${var.environment}-platform"

  tags = {
    Project     = "progress-partners-assessment"
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

module "ecs" {
  source = "../../modules/ecs"

  name                  = "${var.environment}-platform"
  private_subnet_ids    = module.network.private_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_port        = var.app_port
  desired_count         = var.desired_count
  log_retention_days    = 30


  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}

module "monitoring" {
  source = "../../modules/monitoring"

  name               = "${var.environment}-platform"
  cluster_name       = module.ecs.cluster_name
  service_name       = "${var.environment}-platform-service"
  desired_task_count = var.desired_count

  cpu_threshold    = 70
  memory_threshold = 70
  create_alarms    = false
  tags = {
    Project     = "progress-partners-assessment"
    Environment = var.environment
  }
}
