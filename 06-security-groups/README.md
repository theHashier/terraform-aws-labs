# Lab 06 – Security groups

## What this lab demonstrates

This lab shows how to create a **security group** in Terraform: a virtual firewall that allows SSH (22), HTTP (80), and HTTPS (443) from the internet. Security groups are stateful (if traffic is allowed in, the response is allowed out) and are attached to resources like EC2 or load balancers.

## What this lab creates

- **VPC** (10.0.0.0/16) with DNS support and hostnames enabled
- **Security group** with:
  - Ingress: SSH (22), HTTP (80), HTTPS (443) from 0.0.0.0/0
  - Egress: all traffic to 0.0.0.0/0

No EC2 or other compute is created; you can use the security group ID in other labs.

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

- **security_group_id** – ID of the security group (use when launching EC2 or other resources in this VPC)

## Cleanup

```bash
terraform destroy
```

This removes the VPC and security group. No running compute, so cost is effectively zero.
