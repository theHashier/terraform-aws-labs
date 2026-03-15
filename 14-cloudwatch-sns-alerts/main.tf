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
# VPC
########################

resource "aws_vpc" "main" {
  cidr_block           = "10.14.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab14-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.14.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab14-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab14-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "lab14-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

########################
# Security
########################

resource "aws_security_group" "ec2" {
  name   = "lab14-ec2-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab14-ec2-sg"
  }
}

########################
# AMI
########################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

########################
# EC2 instance
########################

resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Generate CPU load in background to trigger the CloudWatch alarm for testing.
  user_data = <<-EOF
#!/bin/bash
yes > /dev/null &
yes > /dev/null &
EOF

  tags = {
    Name = "lab14-ec2"
  }
}

########################
# SNS topic
########################

resource "aws_sns_topic" "alerts" {
  name = "lab14-cloudwatch-alerts"

  tags = {
    Name = "lab14-cloudwatch-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

########################
# CloudWatch alarm
########################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "lab14-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "EC2 CPU utilization above threshold (sends to SNS)"

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
