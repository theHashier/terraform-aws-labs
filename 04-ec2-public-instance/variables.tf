variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.4.1.0/24"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH (e.g. 0.0.0.0/0 or YOUR_IP/32)"
  type        = string
  default     = "0.0.0.0/0"
}
