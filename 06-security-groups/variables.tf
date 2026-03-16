variable "aws_region" {
  description = "AWS region where the security group lab resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.6.0.0/16"
}

variable "allowed_cidr" {
  description = "CIDR allowed for SSH/HTTP/HTTPS (e.g. 0.0.0.0/0 or YOUR_IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}

