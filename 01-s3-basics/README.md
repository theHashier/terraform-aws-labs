## Lab 01 – S3 bucket foundations

### Goal

This lab provisions a **secure S3 bucket** using Terraform with opinionated, production‑style defaults:

- **Deterministic naming** via a configurable prefix.
- **Centralized tagging** using `locals` and provider `default_tags`.
- **Strict public access blocking** at the bucket level.
- **Versioning enabled** to preserve previous object revisions.
- **Lifecycle policy** for short‑lived data under a dedicated prefix.
- **SSE-S3 encryption** as the default for all new objects.

### What gets created

- **S3 bucket**
  - Name is derived from `s3_bucket_name_prefix` and a random suffix added by AWS.
  - Inherits a standard tag set: `Project`, `Lab`, `Environment`, `ManagedBy`.
  - Lifecycle configuration that expires objects stored under the `temp/` prefix after `temp_prefix_expiration_days`.
- **Public access configuration**
  - Public ACLs and bucket policies are blocked.
  - Existing public ACLs are ignored.
  - Public access to the bucket is fully restricted.
- **Versioning**
  - Bucket versioning is turned on to keep historical object versions.
- **Server-side encryption**
  - Default encryption algorithm is `AES256` (SSE-S3 with AWS-managed keys).

### Prerequisites

- Terraform installed.
- AWS credentials exported or configured via `aws configure`.
- Default region `eu-central-1` (can be overridden with a variable).

### Running the lab

From the `01-s3-basics` directory:

```bash
terraform init
terraform plan
terraform apply
```

To switch region or adjust the bucket prefix:

```bash
terraform apply \
  -var="aws_region=eu-central-1" \
  -var="s3_bucket_name_prefix=my-unique-prefix-"
```

> **Note:** `s3_bucket_name_prefix` must be globally unique across AWS accounts. Include something like your name, team, or project.

### Interacting with the bucket

Retrieve the generated bucket name:

```bash
terraform output bucket_name
```

Upload a regular object:

```bash
aws s3 cp example.txt s3://$(terraform output -raw bucket_name)/example.txt
```

Upload a temporary object that should be cleaned up automatically:

```bash
aws s3 cp temp-file.txt s3://$(terraform output -raw bucket_name)/temp/temp-file.txt
```

Objects stored under the `temp/` prefix are removed automatically by S3’s lifecycle engine after `temp_prefix_expiration_days`. Deletion is asynchronous and may not happen immediately.

### Outputs

- `bucket_name` – Name of the S3 lab bucket.
- `bucket_arn` – ARN of the S3 lab bucket.

You can search for the bucket in the AWS console using `bucket_name`, or reference `bucket_arn` in IAM policies used in other labs.

### Cleanup

```bash
terraform destroy
```

Before destroying, ensure the bucket is empty (the lifecycle rule only affects the `temp/` prefix):

```bash
aws s3 rm s3://$(terraform output -raw bucket_name) --recursive
```

After the bucket is empty, run `terraform destroy` to remove all lab resources and avoid unnecessary storage costs.
