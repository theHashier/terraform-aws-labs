variable "region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name (must be globally unique across AWS accounts)"
  type        = string
  default     = "lab01-s3-basics-"
}

variable "temp_prefix_expiration_days" {
  description = "Number of days after which objects under temp/ are automatically expired"
  type        = number
  default     = 30
}

