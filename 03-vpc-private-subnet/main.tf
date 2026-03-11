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
# STEP 1 — DATA
########################

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

########################
# STEP 2 — NETWORK
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
# STEP 3 — ROUTING
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
# STEP 4 — VPC ENDPOINT
########################

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.lab03_vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = {
    Name        = "lab03-s3-endpoint"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# OUTPUTS
########################

output "vpc_id" {
  value = aws_vpc.lab03_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet_a.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet_a.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3_endpoint.id
}