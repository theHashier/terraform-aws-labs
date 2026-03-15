output "instance_id" {
  description = "ID of the EC2 instance (connect via SSM)"
  value       = aws_instance.public_ec2.id
}

output "volume_id" {
  description = "ID of the EBS volume attached to the instance"
  value       = aws_ebs_volume.data_volume.id
}
