# Lab 03 – VPC with public and private subnet (no NAT)

## What this lab demonstrates

This lab shows how to create a **VPC with both a public and a private subnet** using a layout that is closer to production practice. The public subnet has a route to the Internet Gateway; the private subnet has no internet route. There is no NAT Gateway, so you avoid its hourly cost and anything in the private subnet **cannot reach the internet or S3 yet**.

## What this lab creates

- **VPC**:
  - CIDR `vpc_cidr` (default `10.3.0.0/16`) with DNS support and hostnames enabled.
  - Tagged with `Name = lab03-vpc-private-subnet`, plus common lab tags.
- **Internet Gateway** attached to the VPC
- **Public subnet**:
  - CIDR `public_subnet_cidr` (default `10.3.1.0/24`) in the first available AZ, with public IP on launch.
- **Private subnet**:
  - CIDR `private_subnet_cidr` (default `10.3.2.0/24`) in the same AZ, no public IP, no route to the internet.
- **Public route table** with default route (0.0.0.0/0) to the IGW, associated to the public subnet
- **Private route table** with no internet route, associated to the private subnet

Later labs can extend this pattern by adding **NAT Gateways** or **VPC endpoints**; this lab is only about understanding the basic public/private subnet split.

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
  -var="vpc_cidr=10.30.0.0/16" \
  -var="public_subnet_cidr=10.30.1.0/24" \
  -var="private_subnet_cidr=10.30.2.0/24"
```

## Outputs

- **vpc_id** – ID of the VPC
- **public_subnet_id** – ID of the public subnet
- **private_subnet_id** – ID of the private subnet
- **public_route_table_id** – ID of the public route table
- **private_route_table_id** – ID of the private route table
- **vpc_cidr** – CIDR block of the VPC
- **public_subnet_cidr** – CIDR block of the public subnet
- **private_subnet_cidr** – CIDR block of the private subnet

## Cost note

There is no NAT Gateway (no hourly charges). You pay only for the underlying VPC networking components.

## Cleanup

```bash
terraform destroy
```

This removes the VPC, subnets, and route tables.

