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

resource "aws_vpc" "lab12_vpc" {
  cidr_block           = "10.12.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lab12-vpc"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.lab12_vpc.id
  cidr_block              = "10.12.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab12-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.lab12_vpc.id
  cidr_block              = "10.12.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab12-public-subnet-b"
  }
}

resource "aws_internet_gateway" "lab12_igw" {
  vpc_id = aws_vpc.lab12_vpc.id

  tags = {
    Name = "lab12-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab12_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab12_igw.id
  }

  tags = {
    Name = "lab12-public-rt"
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

########################
# STEP 2 — SECURITY
########################

resource "aws_security_group" "alb_sg" {
  name   = "lab12-alb-sg"
  vpc_id = aws_vpc.lab12_vpc.id

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

resource "aws_security_group" "ec2_sg" {
  name   = "lab12-ec2-sg"
  vpc_id = aws_vpc.lab12_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# STEP 3 — IAM
########################

resource "aws_iam_role" "ec2_role" {
  name = "lab12-ec2-role"

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

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab12-ec2-profile"
  role = aws_iam_role.ec2_role.name
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

resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<EOF
#!/bin/bash
dnf install -y httpd
systemctl enable --now httpd
echo "healthy" > /var/www/html/index.html
EOF

  tags = {
    Name = "lab12-public-ec2"
  }
}

########################
# STEP 6 — LOAD BALANCER
########################

resource "aws_lb" "alb" {
  name               = "lab12-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_target_group" "web_tg" {
  name     = "lab12-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab12_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.public_ec2.id
  port             = 80

  depends_on = [aws_instance.public_ec2]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

########################
# OUTPUT
########################

output "alb_dns" {
  value = aws_lb.alb.dns_name
}