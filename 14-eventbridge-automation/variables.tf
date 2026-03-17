variable "aws_region" {
  description = "AWS region where the EventBridge automation lab resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "email_address" {
  description = "Email address to receive EventBridge/SNS notifications"
  type        = string
}

