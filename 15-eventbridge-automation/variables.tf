variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "email_address" {
  description = "Email address to receive EventBridge/SNS notifications"
  type        = string
}

