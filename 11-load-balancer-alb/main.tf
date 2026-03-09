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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
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

resource "aws_security_group" "alb_security_group" {
  name   = "11-alb-sg"
  vpc_id = data.aws_vpc.default.id

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

resource "aws_security_group" "ec2_security_group" {
  name   = "11-ec2-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "11-load-balancer-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_security_group.id]

  tags = {
    Name = "11-load-balancer-alb:alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "11-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_launch_template" "ec2_template" {
  name_prefix   = "11-alb-asg-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from $(hostname)" > /var/www/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "11-alb-ec2"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "11-alb-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 3

  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "11-alb-instance"
    propagate_at_launch = true
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}