locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "security-groups"
  })
}


resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Controls traffic to the application load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB egress is managed by a separate rule below.  
  egress = []

  tags = merge(local.common_tags, {
    Name = "${var.name}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  description = "Allows application traffic only from the ALB."
  vpc_id      = var.vpc_id

  ingress {
    description     = "Application traffic from the ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound traffic required by the application"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-app-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "alb_to_app" {
  description              = "Allow ALB to reach ECS tasks on the application port"
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
}