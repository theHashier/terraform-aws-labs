## Lab 06 – Security groups

### Goal

This lab shows how to create a **security group** in Terraform using the shared bootcamp conventions (locals, `common_tags`, and provider `default_tags`). The security group acts as a virtual firewall that allows SSH (22), HTTP (80), and HTTPS (443) from a configurable CIDR and can be attached to resources like EC2 instances or load balancers.

### What this lab creates

- **VPC**
  - CIDR `vpc_cidr` (default `10.6.0.0/16`) with DNS support and hostnames enabled.
  - Inherits common tags such as `Project`, `Lab`, `Environment`, and `ManagedBy`.
- **Security group**
  - Ingress: SSH (22), HTTP (80), and HTTPS (443) from `allowed_cidr` (default `0.0.0.0/0`).
  - Egress: all traffic to `0.0.0.0/0`.

No EC2 or other compute is created; you can use the security group ID in other labs.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `06-security-groups` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region or allowed CIDR:

```bash
terraform apply \
  -var="aws_region=eu-central-1" \
  -var="allowed_cidr=0.0.0.0/0"
```

### Outputs

- `security_group_id` – ID of the security group (use when launching EC2 or other resources in this VPC).

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the VPC and security group. There is no running compute, so cost is effectively zero.

