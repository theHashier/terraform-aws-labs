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
  lab_id       = "lab-11-load-balancer-alb"
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
# Data
########################

data "aws_vpc" "vpc_default" {
  default = true
}

data "aws_subnets" "subnets_default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

########################
# Security
########################

resource "aws_security_group" "sg_alb" {
  name   = "lab-11-alb"
  vpc_id = data.aws_vpc.vpc_default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ec2" {
  name   = "lab-11-ec2"
  vpc_id = data.aws_vpc.vpc_default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# ALB
########################

resource "aws_lb" "alb" {
  name               = "lab-11-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.subnets_default.ids
  security_groups    = [aws_security_group.sg_alb.id]
}

resource "aws_lb_target_group" "tg_web" {
  name     = "lab-11-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc_default.id
}

resource "aws_lb_listener" "lis_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web.arn
  }
}

########################
# Launch template
########################

resource "aws_launch_template" "lt" {
  name_prefix   = "lab-11-ec2-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  user_data = base64encode(<<EOF
#!/bin/bash
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from $(hostname)" > /var/www/html/index.html
EOF
  )

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
  name = "lab-11-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 3

  vpc_zone_identifier = data.aws_subnets.subnets_default.ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_web.arn]

  tag {
    key                 = "Name"
    value               = "${local.lab_id}-asg-instance"
    propagate_at_launch = true
  }
}