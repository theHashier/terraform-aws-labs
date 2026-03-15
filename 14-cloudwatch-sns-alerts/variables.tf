variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "email_address" {
  description = "Email address for SNS subscription (receives alarm notifications)"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage above which the alarm triggers (default 5 for testing)"
  type        = number
  default     = 5
}

variable "alarm_period" {
  description = "CloudWatch alarm period in seconds (default 60 for testing)"
  type        = number
  default     = 60
}
