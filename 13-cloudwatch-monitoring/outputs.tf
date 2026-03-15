output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch CPU alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}
