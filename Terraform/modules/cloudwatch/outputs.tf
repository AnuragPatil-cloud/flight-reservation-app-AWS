output "jenkins_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.jenkins_cpu.arn
}

output "monitoring_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.monitoring_cpu.arn
}

output "rds_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.rds_cpu.arn
}

output "rds_storage_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.rds_free_storage.arn
}
