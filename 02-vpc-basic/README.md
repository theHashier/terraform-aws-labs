# Lab 02 – VPC basic

## What this lab demonstrates

This lab shows how to create a **basic VPC** with Terraform: a private network in AWS with one public subnet and an Internet Gateway so resources in that subnet can reach the internet. You get familiar with VPC, CIDR, subnets, route tables, and the IGW.

## What this lab creates

- **VPC** (10.0.0.0/16) with DNS support and hostnames enabled
- **Internet Gateway** attached to the VPC
- **Public subnet** (10.0.1.0/24) in the first AZ, with public IP on launch
- **Route table** with a default route (0.0.0.0/0) to the IGW
- **Route table association** linking the public subnet to that route table

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

To override the region:

```bash
terraform apply -var="region=eu-central-1"
```

## Outputs

- **vpc_id** – ID of the VPC
- **public_subnet_id** – ID of the public subnet

## Cleanup

```bash
terraform destroy
```

This removes the VPC, subnet, route table, and Internet Gateway.
