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
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################
# IAM (SSM)
########################

resource "aws_iam_role" "main" {
  name = "lab09-ec2-role"

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

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "main" {
  name = "lab09-ec2-profile"
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
    Name        = "lab09-public-ec2"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# EBS volume
########################

resource "aws_ebs_volume" "main" {
  availability_zone = aws_instance.main.availability_zone
  size              = 8
  type              = "gp3"

  tags = {
    Name        = "lab09-ebs-volume"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_volume_attachment" "main" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.main.id
  instance_id = aws_instance.main.id
}