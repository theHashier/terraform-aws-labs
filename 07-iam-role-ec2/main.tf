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

data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "ec2-role" {
  name = "07-iam-role-ec2@ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3-list-policy" {
  name = "07-iam-role-ec2@s3-list-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.s3-list-policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "07-iam-role-ec2@ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_instance" "public_ec2" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "07-iam-role-ec2:ec2-instance"
  }
}

output "instance_id" {
  value = aws_instance.public_ec2.id
}
