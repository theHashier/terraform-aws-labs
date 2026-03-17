output "security_group_id" {
  description = "ID of the security group (SSH, HTTP, HTTPS)"
  value       = aws_security_group.sg_web.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

