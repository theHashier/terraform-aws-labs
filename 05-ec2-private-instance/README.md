# Lab 05 – EC2 private instance

## What this lab demonstrates

This lab shows how to run an **EC2 instance in a private subnet**: no public IP, no direct internet access. Only resources inside the VPC can reach it. In production you often put databases and backends in private subnets and expose only load balancers or web servers in public subnets. The network layout and naming are aligned with the other “production-style” labs.

## What this lab creates

- **VPC**:
  - CIDR `vpc_cidr` (default `10.5.0.0/16`) with DNS support and hostnames enabled.
  - Tagged with `Name = lab05-ec2-private-vpc`, plus common lab tags.
- **Public subnet**:
  - CIDR `public_subnet_cidr` (default `10.5.1.0/24`) in `${region}a`, with route to the Internet Gateway.
- **Private subnet**:
  - CIDR `private_subnet_cidr` (default `10.5.2.0/24`) in `${region}a`, **no route to the internet**.
- **Internet Gateway** and **route table** for the public subnet.
- **EC2 instance** (t2.micro, Amazon Linux 2023) in the private subnet, no public IP

## Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- Default region `eu-central-1` (can be overridden with a variable)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To override the region or CIDRs:

```bash
terraform apply \
  -var="region=eu-central-1" \
  -var="vpc_cidr=10.5.0.0/16" \
  -var="public_subnet_cidr=10.5.1.0/24" \
  -var="private_subnet_cidr=10.5.2.0/24"
```

## Outputs

- **private_instance_id** – ID of the private EC2 instance
- **vpc_id** – ID of the VPC
- **public_subnet_id** – ID of the public subnet
- **private_subnet_id** – ID of the private subnet
- **vpc_cidr** – CIDR block of the VPC
- **public_subnet_cidr** – CIDR block of the public subnet
- **private_subnet_cidr** – CIDR block of the private subnet

To access the instance you need a bastion in the public subnet or SSM (Session Manager); this lab does not add those.

## Cleanup

```bash
terraform destroy
```

This removes the VPC, subnets, route table, and EC2 instance.
