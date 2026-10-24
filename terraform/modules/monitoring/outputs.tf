output "cpu_alarm_name" {
  description = "Name of the ECS CPU utilization alarm."
  value       = var.create_alarms ? aws_cloudwatch_metric_alarm.cpu_high[0].alarm_name : null
}

output "memory_alarm_name" {
  description = "Name of the ECS memory utilization alarm."
  value       = var.create_alarms ? aws_cloudwatch_metric_alarm.memory_high[0].alarm_name : null
}

output "running_tasks_alarm_name" {
  description = "Name of the running task count alarm."
  value       = var.create_alarms ? aws_cloudwatch_metric_alarm.running_tasks_low[0].alarm_name : null
}