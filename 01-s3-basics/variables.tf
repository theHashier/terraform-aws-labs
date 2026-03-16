variable "aws_region" {
  description = "AWS region where the S3 lab bucket will be created"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_name_prefix" {
  description = "Prefix used when generating the S3 bucket name (must be globally unique across AWS)"
  type        = string
  default     = "lab-01-s3-basics-"
}

variable "temp_prefix_expiration_days" {
  description = "Number of days after which objects stored under the temp/ prefix are automatically expired"
  type        = number
  default     = 30
}

