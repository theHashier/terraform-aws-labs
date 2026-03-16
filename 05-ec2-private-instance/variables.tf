variable "aws_region" {
  description = "AWS region where the EC2 private instance lab resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.5.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet in availability zone a"
  type        = string
  default     = "10.5.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet in availability zone a"
  type        = string
  default     = "10.5.2.0/24"
}

