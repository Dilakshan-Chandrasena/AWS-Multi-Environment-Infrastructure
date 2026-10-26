
locals {
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "monitoring"
  })
}

data "aws_region" "current" {}

resource "aws_sns_topic" "alerts" {
  count = var.create_alarms ? 1 : 0

  name = "${var.name}-alerts"

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.create_alarms ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-ecs-cpu-high"
  alarm_description   = "ECS service CPU utilization is above the configured threshold."
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
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
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
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
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
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



resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-alb-5xx"
  alarm_description   = "ALB-generated HTTP 5xx errors reached the configured threshold."
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-target-5xx"
  alarm_description   = "Application targets returned HTTP 5xx errors at or above the configured threshold."
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.target_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${var.name}-unhealthy-targets"
  alarm_description   = "At least one unhealthy target was reported by the ALB."
  alarm_actions       = [aws_sns_topic.alerts[0].arn]
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_dashboard" "platform" {
  count = var.create_alarms ? 1 : 0

  dashboard_name = "${var.name}-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU and Memory Utilization"
          region = data.aws_region.current.region
          period = 300
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS Running Tasks"
          region = data.aws_region.current.region
          period = 300
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB and Target HTTP 5xx Errors"
          region = data.aws_region.current.region
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Unhealthy Application Targets"
          region = data.aws_region.current.region
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
        }
      }
    ]
  })
}
