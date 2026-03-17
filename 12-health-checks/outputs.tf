output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_http_url" {
  description = "HTTP URL for the ALB (port 80)"
  value       = "http://${aws_lb.alb.dns_name}"
}
