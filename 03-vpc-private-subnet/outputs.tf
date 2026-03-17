output "vpc_id" {
  description = "ID of the primary VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet in AZ a"
  value       = aws_subnet.subnet_public_a.id
}

output "private_subnet_id" {
  description = "ID of the private subnet in AZ a"
  value       = aws_subnet.subnet_private_a.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.rt_public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.rt_private.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.subnet_public_a.cidr_block
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.subnet_private_a.cidr_block
}

