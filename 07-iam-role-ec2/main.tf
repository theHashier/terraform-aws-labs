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
# AMI
########################

data "aws_ami" "al2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################
# IAM
########################

resource "aws_iam_role" "main" {
  name = "lab07-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_list" {
  name = "lab07-s3-list-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListAllMyBuckets"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.s3_list.arn
}

resource "aws_iam_instance_profile" "main" {
  name = "lab07-ec2-profile"
  role = aws_iam_role.main.name
}

########################
# EC2 instance
########################

resource "aws_instance" "main" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Name        = "lab07-public-ec2"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}