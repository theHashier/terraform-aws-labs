terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

########################
# S3 bucket
########################

resource "aws_s3_bucket" "main" {
  bucket_prefix = var.bucket_prefix

  tags = {
    Name        = "lab01-s3-basics"
    Environment = "lab"
    ManagedBy   = "terraform"
  }

  lifecycle_rule {
    id      = "expire-temp-objects"
    enabled = true

    prefix = "temp/"

    expiration {
      days = var.temp_prefix_expiration_days
    }
  }
}

########################
# Bucket protection
########################

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
