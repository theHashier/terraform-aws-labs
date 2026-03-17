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
  lab_id       = "lab-13b-cloudwatch-sns-alerts"
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
# VPC
########################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.14.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.14.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rt_public.id
}

########################
# Security
########################

resource "aws_security_group" "sg_ec2" {
  name   = "lab-13b-ec2"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_public_a.id

  vpc_security_group_ids = [aws_security_group.sg_ec2.id]

  # Generate CPU load in background to trigger the CloudWatch alarm for testing.
  user_data = <<-EOF
#!/bin/bash
yes > /dev/null &
yes > /dev/null &
EOF

}

########################
# SNS topic
########################

resource "aws_sns_topic" "sns_alerts" {
  name = "lab-13b-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "sub_email" {
  topic_arn = aws_sns_topic.sns_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

########################
# CloudWatch alarm
########################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "lab-13b-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "EC2 CPU utilization above threshold (sends to SNS)"

  dimensions = {
    InstanceId = aws_instance.ec2.id
  }

  alarm_actions = [aws_sns_topic.sns_alerts.arn]
}
