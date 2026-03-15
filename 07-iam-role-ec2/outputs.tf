output "instance_id" {
  description = "ID of the EC2 instance with IAM role"
  value       = aws_instance.public_ec2.id
}
