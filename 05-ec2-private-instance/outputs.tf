output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.primary.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_a.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_a.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.primary.cidr_block
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public_a.cidr_block
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.private_a.cidr_block
}

