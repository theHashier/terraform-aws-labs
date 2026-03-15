# Lab 04 – EC2 public instance

## What this lab demonstrates

This lab shows how to launch an **EC2 instance in a public subnet** with Terraform: VPC, subnet, Internet Gateway, security group (SSH), and an EC2 instance with a public IP so you can SSH in. You use an existing EC2 Key Pair and optionally restrict SSH to your IP.

## What this lab creates

- **VPC** (10.40.0.0/16) with DNS support and hostnames enabled
- **Internet Gateway** and **public subnet** (10.40.1.0/24) with route to the internet
- **Security group** allowing SSH (port 22) from a configurable CIDR
- **EC2 instance** (t2.micro, Amazon Linux 2023) with public IP and the Key Pair you specify

## Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- An existing **EC2 Key Pair** in the region (create in EC2 → Key Pairs)
- Default region `eu-central-1` (can be overridden)

## Usage

Set the key pair name (required). Optionally set SSH CIDR in `terraform.tfvars`:

```hcl
key_name  = "your-keypair-name"
ssh_cidr  = "0.0.0.0/0"   # or "YOUR_IP/32" to restrict SSH
```

Then:

```bash
terraform init
terraform plan -var="key_name=your-keypair-name"
terraform apply -var="key_name=your-keypair-name"
```

To override the region:

```bash
terraform apply -var="key_name=your-keypair-name" -var="region=eu-central-1"
```

## Outputs

- **instance_id** – ID of the EC2 instance
- **public_ip** – Public IP of the EC2 instance
- **public_dns** – Public DNS name of the EC2 instance

Use `public_ip` or `public_dns` to SSH: `ssh -i your-key.pem ec2-user@<public_ip>`.

## Cleanup

```bash
terraform destroy -var="key_name=your-keypair-name"
```

This removes the VPC, subnet, security group, and EC2 instance.
