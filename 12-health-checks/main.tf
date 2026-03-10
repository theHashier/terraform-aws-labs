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
# STEP 1 — NETWORK
########################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.12.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "12-health-checks-vpc"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.12.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "12-health-checks-public-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.12.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "12-health-checks-public-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "12-health-checks-igw"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "12-health-checks-route-table"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.route-table.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.route-table.id
}

########################
# STEP 2 — SECURITY
########################

resource "aws_security_group" "alb-sg" {
  name   = "12-health-checks-alb-sg"
  vpc_id = aws_vpc.vpc.id

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

resource "aws_security_group" "ec2-sg" {
  name   = "12-health-checks-ec2-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# STEP 3 — IAM (SSM)
########################

resource "aws_iam_role" "ec2-role" {
  name = "12-health-checks-ec2-role"

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

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "12-health-checks-ec2-profile"
  role = aws_iam_role.ec2-role.name
}

########################
# STEP 4 — AMI
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
# STEP 5 — EC2
########################

resource "aws_instance" "public-ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet-a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<EOF
#!/bin/bash
dnf install -y httpd
systemctl enable --now httpd
echo "healthy" > /var/www/html/index.html
EOF

  tags = {
    Name = "12-health-checks-public-ec2"
  }
}

########################
# STEP 6 — LOAD BALANCER
########################

resource "aws_lb" "alb" {
  name               = "lab12-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "public-alb" {
  name     = "lab12-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "public-target-group-attachment" {
  target_group_arn = aws_lb_target_group.public-alb.arn
  target_id        = aws_instance.public-ec2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-alb.arn
  }
}

########################
# OUTPUT
########################

output "alb_dns" {
  value = aws_lb.alb.dns_name
}