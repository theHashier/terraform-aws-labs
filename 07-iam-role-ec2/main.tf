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

########################
# STEP 1 — AMI
########################

data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

########################
# STEP 2 — IAM
########################

resource "aws_iam_role" "ec2_role" {
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

resource "aws_iam_policy" "s3_list_policy" {
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

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_list_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab07-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

########################
# STEP 3 — COMPUTE
########################

resource "aws_instance" "public_ec2" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name        = "lab07-public-ec2"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# OUTPUTS
########################

output "instance_id" {
  value = aws_instance.public_ec2.id
}