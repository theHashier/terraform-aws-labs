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
# STEP 1 — AMI
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
# STEP 2 — NETWORK
########################

resource "aws_vpc" "lab05_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "lab05-vpc"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.lab05_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name        = "lab05-public-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.lab05_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name        = "lab05-private-subnet-a"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

resource "aws_internet_gateway" "lab05_igw" {
  vpc_id = aws_vpc.lab05_vpc.id

  tags = {
    Name        = "lab05-igw"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# STEP 3 — ROUTING
########################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab05_vpc.id

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
  gateway_id             = aws_internet_gateway.lab05_igw.id
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

########################
# STEP 4 — COMPUTE
########################

resource "aws_instance" "private_ec2" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_a.id

  tags = {
    Name        = "lab05-private-ec2"
    Environment = "lab"
    ManagedBy   = "terraform"
    Owner       = "Eugen"
  }
}

########################
# OUTPUTS
########################

output "private_instance_id" {
  value = aws_instance.private_ec2.id
}