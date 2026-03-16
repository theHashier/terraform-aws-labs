output "bucket_name" {
  description = "Name of the S3 bucket that emits events"
  value       = aws_s3_bucket.events.bucket
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic that receives EventBridge events"
  value       = aws_sns_topic.notifications.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.s3_put_object.arn
}

