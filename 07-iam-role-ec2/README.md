## Lab 07 – IAM role for EC2

### Goal

This lab shows how to attach an **IAM role to an EC2 instance** using an instance profile, following the shared bootcamp conventions (locals, `common_tags`, and provider `default_tags`). The role includes a policy that allows listing S3 buckets (`s3:ListAllMyBuckets`). The instance runs in the default VPC and can call AWS APIs with these permissions without access keys.

### What this lab creates

- **IAM role** that EC2 can assume.
- **IAM policy** allowing `s3:ListAllMyBuckets` on `*`.
- **Role–policy attachment** and **instance profile** linking the role to EC2.
- **EC2 instance** (`t2.micro`, Amazon Linux 2023) in the default VPC with the instance profile attached.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `07-iam-role-ec2` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="aws_region=eu-central-1"
```

### Outputs

- `instance_id` – ID of the EC2 instance with the IAM role.
- `iam_role_name` – Name of the IAM role attached to EC2.
- `iam_instance_profile_name` – Name of the IAM instance profile attached to EC2.

You can connect to the instance (SSM or SSH, if allowed) and run `aws s3 ls` to verify the role permissions.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the EC2 instance, instance profile, role, and policy. Only the `t2.micro` instance incurs cost while it runs.
