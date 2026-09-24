output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "subscription_arn" {
  value = aws_sns_topic_subscription.email.arn
}
