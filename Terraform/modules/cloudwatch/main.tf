resource "aws_cloudwatch_metric_alarm" "jenkins_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-jenkins-high-cpu"
  alarm_description   = "Jenkins EC2 CPU is high"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { InstanceId = var.jenkins_instance_id }
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = 2
  threshold           = var.ec2_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "monitoring_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-monitoring-high-cpu"
  alarm_description   = "Monitoring EC2 CPU is high"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { InstanceId = var.monitoring_instance_id }
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = 2
  threshold           = var.ec2_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  alarm_description   = "RDS CPU is high"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  dimensions          = { DBInstanceIdentifier = var.rds_instance_id }
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = 2
  threshold           = var.rds_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-free-storage"
  alarm_description   = "RDS free storage is low"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  dimensions          = { DBInstanceIdentifier = var.rds_instance_id }
  statistic           = "Average"
  period              = var.period
  evaluation_periods  = 1
  threshold           = var.rds_free_storage_threshold
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "breaching"
}
