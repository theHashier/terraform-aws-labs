output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.primary.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_a.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.primary.cidr_block
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public_a.cidr_block
}

