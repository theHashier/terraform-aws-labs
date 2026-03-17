output "instance_id" {
  description = "ID of the EC2 instance (connect via SSM Session Manager)"
  value       = aws_instance.ec2.id
}

output "iam_role_name" {
  description = "Name of the IAM role attached to EC2 for SSM"
  value       = aws_iam_role.role_ec2.name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to EC2"
  value       = aws_iam_instance_profile.profile_ec2.name
}

