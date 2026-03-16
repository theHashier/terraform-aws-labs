## Lab 05 – EC2 private instance

### Goal

This lab shows how to run an **EC2 instance in a private subnet** using the shared bootcamp conventions (locals, `common_tags`, and provider `default_tags`): no public IP, no direct internet access, and only resources inside the VPC can reach it. In production you often put databases and backends in private subnets and expose only load balancers or web servers in public subnets.

### What this lab creates

- **VPC**
  - CIDR `vpc_cidr` (default `10.5.0.0/16`) with DNS support and hostnames enabled.
  - Inherits common tags such as `Project`, `Lab`, `Environment`, and `ManagedBy`.
- **Public subnet (AZ a)**
  - CIDR `public_subnet_cidr` (default `10.5.1.0/24`) in `${aws_region}a`, with a route to the Internet Gateway.
- **Private subnet (AZ a)**
  - CIDR `private_subnet_cidr` (default `10.5.2.0/24`) in `${aws_region}a`, **no route to the internet**.
- **Internet Gateway and public route table**
  - Internet Gateway attached to the VPC.
  - Public route table with default route `0.0.0.0/0` via the Internet Gateway, associated with the public subnet.
- **EC2 instance**
  - `t2.micro`, Amazon Linux 2023, launched in the private subnet with no public IP.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `05-ec2-private-instance` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region or CIDR blocks:

```bash
terraform apply \
  -var="aws_region=eu-central-1" \
  -var="vpc_cidr=10.5.0.0/16" \
  -var="public_subnet_cidr=10.5.1.0/24" \
  -var="private_subnet_cidr=10.5.2.0/24"
```

### Outputs

- `private_instance_id` – ID of the private EC2 instance.
- `vpc_id` – ID of the VPC.
- `public_subnet_id` – ID of the public subnet.
- `private_subnet_id` – ID of the private subnet.
- `vpc_cidr` – CIDR block of the VPC.
- `public_subnet_cidr` – CIDR block of the public subnet.
- `private_subnet_cidr` – CIDR block of the private subnet.

To access the instance you would typically use a bastion host in the public subnet or SSM (Session Manager); this lab intentionally does not add those components.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the VPC, subnets, route table, and EC2 instance that were created.

