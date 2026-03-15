variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
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
