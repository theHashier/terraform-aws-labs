# Lab 08 – EC2 with SSM

## What this lab demonstrates

This lab shows how to run an **EC2 instance that you can access with Systems Manager Session Manager**—no SSH key or open port 22. The instance has an IAM role with `AmazonSSMManagedInstanceCore`, so SSM can reach it in the default VPC.

## What this lab creates

- **IAM role** that EC2 can assume
- **Attachment** of the managed policy `AmazonSSMManagedInstanceCore` to the role
- **Instance profile** linking the role to EC2
- **EC2 instance** (t2.micro, Amazon Linux 2023) in the default VPC with the instance profile

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

- **instance_id** – ID of the EC2 instance (use for SSM Session Manager)

Connect in the AWS Console: **EC2 → Instances → Select instance → Connect → Session Manager**. Or use the AWS CLI with the instance ID.

## Cleanup

```bash
terraform destroy
```

This removes the EC2 instance, instance profile, and IAM role. Only the t2.micro instance incurs cost while it runs.
