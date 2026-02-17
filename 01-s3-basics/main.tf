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

resource "aws_s3_bucket" "lab" {
  bucket_prefix = "eugen-tf-lab-"
}

output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}
