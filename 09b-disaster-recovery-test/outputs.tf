output "instance_id" {
  description = "ID of the EC2 instance restored from the snapshot"
  value       = aws_instance.ec2.id
}

output "restored_volume_id" {
  description = "ID of the EBS volume created from the snapshot"
  value       = aws_ebs_volume.vol_data.id
}

