
output "cpu_alarm_name" {
  description = "Name of the ECS CPU utilization alarm."
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "memory_alarm_name" {
  description = "Name of the ECS memory utilization alarm."
  value       = aws_cloudwatch_metric_alarm.memory_high.alarm_name
}

output "running_tasks_alarm_name" {
  description = "Name of the running task count alarm."
  value       = aws_cloudwatch_metric_alarm.running_tasks_low.alarm_name
}
