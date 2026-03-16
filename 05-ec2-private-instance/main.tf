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

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lab05-ec2-private-vpc"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab05-public-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name        = "lab05-private-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "lab05-igw"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

########################
# Routing
########################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "lab05-public-rt"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

########################
# EC2 instance
########################

resource "aws_instance" "private_ec2" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id

  tags = {
    Name        = "lab05-private-ec2"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}