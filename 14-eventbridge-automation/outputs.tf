output "bucket_name" {
  description = "Name of the S3 bucket that emits events"
  value       = aws_s3_bucket.s3_events.bucket
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic that receives EventBridge events"
  value       = aws_sns_topic.sns_notifications.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.rule_s3_put_object.arn
}

