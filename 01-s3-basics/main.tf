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
  region = "eu-central-1"
}

resource "aws_s3_bucket" "s3" {
  bucket_prefix = "eugen-tf-s3-"

  tags = {
    Name = "01-s3-basic:s3"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.s3.bucket
}
