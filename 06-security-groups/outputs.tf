output "security_group_id" {
  description = "ID of the security group (SSH, HTTP, HTTPS)"
  value       = aws_security_group.web_ssh_sg.id
}
