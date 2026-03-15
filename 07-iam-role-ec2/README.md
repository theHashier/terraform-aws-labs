# Lab 07 – IAM role for EC2

## What this lab demonstrates

This lab shows how to attach an **IAM role to an EC2 instance** using an instance profile. The role has a policy that allows listing S3 buckets (`s3:ListAllMyBuckets`). The instance runs in the default VPC and can call AWS APIs with these permissions without access keys.

## What this lab creates

- **IAM role** that EC2 can assume
- **IAM policy** allowing `s3:ListAllMyBuckets` on `*`
- **Role–policy attachment** and **instance profile** linking the role to EC2
- **EC2 instance** (t2.micro, Amazon Linux 2023) in the default VPC with the instance profile attached

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

- **instance_id** – ID of the EC2 instance with the IAM role

You can SSM or SSH into the instance (if allowed) and run `aws s3 ls` to see the role in use.

## Cleanup

```bash
terraform destroy
```

This removes the EC2 instance, instance profile, role, and policy. Only the t2.micro instance incurs cost while it runs.
