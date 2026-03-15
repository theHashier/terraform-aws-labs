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
# Data
########################

data "aws_availability_zones" "available" {
  state = "available"
}

########################
# VPC
########################

resource "aws_vpc" "lab03_vpc" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "lab03-vpc"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_internet_gateway" "lab03_igw" {
  vpc_id = aws_vpc.lab03_vpc.id

  tags = {
    Name        = "lab03-igw"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.lab03_vpc.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab03-public-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.lab03_vpc.id
  cidr_block              = "10.30.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name        = "lab03-private-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# Routing
########################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab03_vpc.id

  tags = {
    Name        = "lab03-public-rt"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab03_igw.id
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.lab03_vpc.id

  tags = {
    Name        = "lab03-private-rt"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

########################
# VPC endpoint
########################

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.lab03_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = {
    Name        = "lab03-s3-endpoint"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}