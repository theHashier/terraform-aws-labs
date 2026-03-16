output "instance_id" {
  description = "ID of the EC2 instance with IAM role"
  value       = aws_instance.public_ec2.id
}

output "iam_role_name" {
  description = "Name of the IAM role attached to EC2"
  value       = aws_iam_role.ec2_role.name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}

