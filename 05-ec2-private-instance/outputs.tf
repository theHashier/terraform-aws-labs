output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private_ec2.id
}
