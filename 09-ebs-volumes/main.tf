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
  name = "09-ebs-volumes-ec2-role"

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

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "09-ebs-volumes-ec2-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_instance" "public-ec2" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  tags = {
    Name = "09-ebs-volumes-public-ec2"
  }
}

resource "aws_ebs_volume" "ebs-volume" {
  availability_zone = aws_instance.public-ec2.availability_zone
  size              = 8
  type              = "gp3"

  tags = {
    Name = "09-ebs-volumes-ebs-volume"
  }
}

resource "aws_volume_attachment" "disk-attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.ebs-volume.id
  instance_id = aws_instance.public-ec2.id
}

output "instance_id" {
  value = aws_instance.public-ec2.id
}

output "volume_id" {
  value = aws_ebs_volume.ebs-volume.id
}
