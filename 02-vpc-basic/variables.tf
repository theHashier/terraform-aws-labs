variable "region" {
  description = "AWS region for the VPC"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet in AZ a"
  type        = string
  default     = "10.2.1.0/24"
}

