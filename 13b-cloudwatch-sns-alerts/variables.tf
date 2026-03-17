variable "aws_region" {
  description = "AWS region where the CloudWatch + SNS alerts lab resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "email_address" {
  description = "Email address for SNS subscription (receives alarm notifications)"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage above which the alarm triggers (default 70)"
  type        = number
  default     = 70
}

variable "alarm_period" {
  description = "CloudWatch alarm period in seconds"
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "Number of evaluation periods required to trigger the alarm"
  type        = number
  default     = 1
}
