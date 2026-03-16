variable "aws_region" {
  description = "AWS region where the VPC lab resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet in availability zone a"
  type        = string
  default     = "10.2.1.0/24"
}

