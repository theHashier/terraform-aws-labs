# Lab 01 – S3 basics

## What this lab demonstrates

This lab shows how to create a **simple S3 bucket** with Terraform. S3 is AWS’s object storage service used for images, backups, logs, and many other types of files. The bucket is named using a prefix and a random suffix so it stays unique across AWS accounts and regions.

## What this lab creates

- **S3 bucket** with:
  - `bucket_prefix = "tf-s3-"` (unique bucket name per run)
  - Tags: `Name`, `Environment`, `ManagedBy`, `Owner`

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

- **bucket_name** – Name of the S3 bucket that was created

You can find the bucket in the AWS Console under S3 using the output value.

## Cleanup

```bash
terraform destroy
```

This removes the S3 bucket so you don’t pay for unused storage.
