terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  project_name = "terraform-aws-labs"
  lab_id       = "lab-10-auto-scaling-group"
  environment  = "lab"

  common_tags = {
    Name        = local.lab_id
    Project     = local.project_name
    Lab         = local.lab_id
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

########################
# AMI
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
# Launch template
########################

resource "aws_launch_template" "lt" {
  name_prefix   = "lab-10-ec2-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.lab_id}-ec2"
    }
  }
}

########################
# Auto Scaling Group
########################

resource "aws_autoscaling_group" "asg" {
  name = "lab-10-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]

  tag {
    key                 = "Name"
    value               = "${local.lab_id}-asg-instance"
    propagate_at_launch = true
  }
}