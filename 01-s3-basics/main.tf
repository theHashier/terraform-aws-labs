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

resource "aws_s3_bucket" "lab01_s3" {
  bucket_prefix = "tf-s3-"

  tags = {
    Name        = "lab01-s3-bucket"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}