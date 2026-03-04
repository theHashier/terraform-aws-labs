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

data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lab-05-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-05-public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "lab-04-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab-05-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lab-05-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_instance" "private_ec2" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet.id

  tags = {
    Name = "lab-05-private-ec2"
  }
}

output "private_instance_id" {
  value = aws_instance.private_ec2.id
}
