output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2.public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.subnet_public_a.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.subnet_public_a.cidr_block
}

