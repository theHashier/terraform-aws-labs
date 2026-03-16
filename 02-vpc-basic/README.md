## Lab 02 – VPC basics

### Goal

This lab provisions a **small, production‑style VPC layout** with Terraform: a single VPC, one public subnet, and Internet access through an Internet Gateway, using the same conventions as the other labs (locals, default tags, and consistent naming).

### What this lab creates

- **VPC**
  - CIDR block `vpc_cidr` (default `10.2.0.0/16`) with DNS support and hostnames enabled.
  - Inherits common tags such as `Project`, `Lab`, `Environment`, and `ManagedBy`.
- **Internet Gateway**
  - Attached to the primary VPC.
- **Public subnet (AZ a)**
  - CIDR block `public_subnet_cidr` (default `10.2.1.0/24`) in availability zone `${aws_region}a`.
  - `map_public_ip_on_launch = true` so instances launched here receive public IPs by default.
- **Public route table**
  - Default route `0.0.0.0/0` to the Internet Gateway.
  - Associated with the public subnet.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `02-vpc-basic` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region or CIDR blocks:

```bash
terraform apply \
  -var="aws_region=eu-central-1" \
  -var="vpc_cidr=10.20.0.0/16" \
  -var="public_subnet_cidr=10.20.1.0/24"
```

### Outputs

- `vpc_id` – ID of the primary VPC.
- `public_subnet_id` – ID of the public subnet in AZ a.
- `vpc_cidr` – CIDR block of the VPC.
- `public_subnet_cidr` – CIDR block of the public subnet.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the VPC, subnet, route table, and Internet Gateway that were created.
