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
  lab_id       = "lab-02-vpc-basic"
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

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_public_internet" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rt_public.id
}