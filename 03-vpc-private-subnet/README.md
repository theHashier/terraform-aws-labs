## Lab 03 – VPC with public and private subnet (no NAT)

### Goal

This lab provisions a **VPC with both a public and a private subnet** using the same conventions as the other labs (locals, default tags, and consistent naming). The public subnet has a route to the Internet Gateway; the private subnet has no route to the internet. There is no NAT Gateway, so anything in the private subnet **cannot reach the internet or S3 yet**.

### What this lab creates

- **VPC**
  - CIDR `vpc_cidr` (default `10.3.0.0/16`) with DNS support and hostnames enabled.
  - Inherits common tags such as `Project`, `Lab`, `Environment`, and `ManagedBy`.
- **Internet Gateway**
  - Attached to the primary VPC.
- **Public subnet (AZ a)**
  - CIDR `public_subnet_cidr` (default `10.3.1.0/24`) in the first available availability zone.
  - `map_public_ip_on_launch = true` so instances launched here receive public IPs.
- **Private subnet (AZ a)**
  - CIDR `private_subnet_cidr` (default `10.3.2.0/24`) in the same availability zone.
  - `map_public_ip_on_launch = false` and **no route to the internet**.
- **Public route table**
  - Default route `0.0.0.0/0` to the Internet Gateway.
  - Associated with the public subnet.
- **Private route table**
  - No internet route.
  - Associated with the private subnet.

Later labs can extend this pattern by adding **NAT Gateways** or **VPC endpoints**; this lab focuses purely on the public/private subnet split.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `03-vpc-private-subnet` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region or CIDR blocks:

```bash
terraform apply \
  -var="aws_region=eu-central-1" \
  -var="vpc_cidr=10.30.0.0/16" \
  -var="public_subnet_cidr=10.30.1.0/24" \
  -var="private_subnet_cidr=10.30.2.0/24"
```

### Outputs

- `vpc_id` – ID of the primary VPC.
- `public_subnet_id` – ID of the public subnet.
- `private_subnet_id` – ID of the private subnet.
- `public_route_table_id` – ID of the public route table.
- `private_route_table_id` – ID of the private route table.
- `vpc_cidr` – CIDR block of the VPC.
- `public_subnet_cidr` – CIDR block of the public subnet.
- `private_subnet_cidr` – CIDR block of the private subnet.

### Cost note

There is no NAT Gateway (no hourly charges). You pay only for the underlying VPC networking components.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the VPC, subnets, and route tables that were created.

