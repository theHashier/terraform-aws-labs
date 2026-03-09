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

resource "aws_launch_template" "ec2_template" {
  name_prefix   = "10-auto-scaling-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "10-auto-scaling:ec2"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "10-auto-scaling-group"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  availability_zones = ["eu-central-1a", "eu-central-1b"]

  tag {
    key                 = "Name"
    value               = "10-auto-scaling:instance"
    propagate_at_launch = true
  }
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.asg.name
}
