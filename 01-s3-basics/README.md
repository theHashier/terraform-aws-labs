# Lab 01 – S3 basics

## What this lab demonstrates

This lab shows how to create a **production‑style S3 bucket** with Terraform, not just a bare bucket. You will see:

- How to **generate a unique bucket name** with a prefix.
- How to **block public access** at the bucket level.
- How to **enable versioning** to keep old copies of objects.
- How to add a simple **lifecycle rule** for short‑lived data under a specific prefix.

## What this lab creates

- **S3 bucket**:
  - `bucket_prefix` (variable, default `lab01-s3-basics-`) – AWS adds a random suffix for global uniqueness.
  - Tags: `Name`, `Environment`, `ManagedBy`.
  - **Lifecycle rule**: objects under the `temp/` prefix are automatically expired after `temp_prefix_expiration_days` (default 30).
- **Public access block**:
  - Blocks public ACLs and public bucket policies.
- **Versioning**:
  - Enabled to keep previous versions of objects.
- **Server-side encryption (SSE-S3)**:
  - Default encryption with AWS-managed keys (`AES256`).

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

To override the region or bucket prefix:

```bash
terraform apply \
  -var="region=eu-central-1" \
  -var="bucket_prefix=my-unique-prefix-"
```

> **Note:** `bucket_prefix` must be globally unique across AWS (e.g. include your name or project).

### Interacting with the bucket

After `apply`, get the bucket name:

```bash
terraform output bucket_name
```

Upload a file:

```bash
aws s3 cp example.txt s3://$(terraform output -raw bucket_name)/example.txt
```

Upload a temporary file that should expire automatically (under `temp/`):

```bash
aws s3 cp temp-file.txt s3://$(terraform output -raw bucket_name)/temp/temp-file.txt
```

Over time (after `temp_prefix_expiration_days`), objects under `temp/` will be deleted by S3’s lifecycle engine. This is not instant; it is a background process.

## Outputs

- **bucket_name** – Name of the S3 bucket.
- **bucket_arn** – ARN of the S3 bucket.

You can find the bucket in the AWS Console under S3 using `bucket_name`, or use `bucket_arn` for IAM policies in other labs.

## Cleanup

```bash
terraform destroy
```

Before destroying, ensure the bucket is empty (S3 lifecycle will eventually clean up `temp/`, but other prefixes remain):

```bash
aws s3 rm s3://$(terraform output -raw bucket_name) --recursive
```

Then run `terraform destroy`. This removes the S3 bucket so you don’t pay for unused storage.
