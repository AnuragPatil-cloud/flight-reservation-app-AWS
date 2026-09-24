output "alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.jenkins_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.monitoring_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_storage.alarm_name,
  ]
}
