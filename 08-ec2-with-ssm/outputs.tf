output "instance_id" {
  description = "ID of the EC2 instance (connect via SSM Session Manager)"
  value       = aws_instance.public_ec2.id
}
