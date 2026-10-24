
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "monitoring"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-ecs-cpu-high"
  alarm_description   = "ECS service CPU utilization is above the configured threshold."
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.create_alarms ? 1 : 0
  alarm_name          = "${var.name}-ecs-memory-high"
  alarm_description   = "ECS service memory utilization is above the configured threshold."
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.memory_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "running_tasks_low" {
  count               = var.create_alarms ? 1 : 0
  alarm_name          = "${var.name}-ecs-running-tasks-low"
  alarm_description   = "ECS service has fewer running tasks than desired."
  namespace           = "ECS/ContainerInsights"
  metric_name         = "RunningTaskCount"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.desired_task_count
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = local.common_tags
}
