
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "ecs"
  })

  container_name = "${var.name}-app"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

data "aws_ecs_task_definition" "app" {
  count = var.create_service ? 1 : 0

  task_definition = "${var.name}-task"
}

resource "aws_ecs_service" "app" {
  count = var.create_service ? 1 : 0

  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = data.aws_ecs_task_definition.app[0].arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    aws_cloudwatch_log_group.app
  ]

  tags = local.common_tags
}
