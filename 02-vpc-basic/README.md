# Lab 02 – VPC basic

## What this lab demonstrates

This lab shows how to create a **production‑style basic VPC** with Terraform: a small, opinionated network layout with a single public subnet and Internet access. You get familiar with VPCs, CIDR blocks, subnets, route tables, and the Internet Gateway, but with naming and variables that are closer to real projects.

## What this lab creates

- **VPC**:
  - CIDR `vpc_cidr` (default `10.2.0.0/16`) with DNS support and hostnames enabled.
  - Tagged with `Name = lab02-vpc-basic`, plus common lab tags.
- **Internet Gateway** attached to the VPC.
- **Public subnet**:
  - CIDR `public_subnet_cidr` (default `10.2.1.0/24`) in AZ `${region}a`.
  - Configured with `map_public_ip_on_launch = true` so instances get public IPs by default.
- **Public route table**:
  - Default route `0.0.0.0/0` to the Internet Gateway.
  - Associated with the public subnet.

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
  -var="vpc_cidr=10.20.0.0/16" \
  -var="public_subnet_cidr=10.20.1.0/24"
```

## Outputs

- **vpc_id** – ID of the VPC.
- **public_subnet_id** – ID of the public subnet.
- **vpc_cidr** – CIDR block of the VPC.
- **public_subnet_cidr** – CIDR block of the public subnet.

## Cleanup

```bash
terraform destroy
```

This removes the VPC, subnet, route table, and Internet Gateway.
