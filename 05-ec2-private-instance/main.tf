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
  lab_id       = "lab-05-ec2-private-instance"
  environment  = "lab"

  common_tags = {
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
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################
# VPC
########################

resource "aws_vpc" "primary" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"
}

resource "aws_internet_gateway" "primary" {
  vpc_id = aws_vpc.primary.id
}

########################
# Routing
########################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.primary.id
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

########################
# EC2 instance
########################

resource "aws_instance" "private" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_a.id
}