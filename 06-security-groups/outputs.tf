output "security_group_id" {
  description = "ID of the security group (SSH, HTTP, HTTPS)"
  value       = aws_security_group.web_ssh.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

