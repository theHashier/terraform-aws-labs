## Lab 08 – EC2 with SSM

### Goal

This lab shows how to run an **EC2 instance that you can access with Systems Manager Session Manager**—no SSH key or open port 22—using the shared bootcamp conventions (locals, `common_tags`, and provider `default_tags`). The instance has an IAM role with the managed policy `AmazonSSMManagedInstanceCore`, so SSM can reach it in the default VPC.

### What this lab creates

- **IAM role** that EC2 can assume.
- **Attachment** of the managed policy `AmazonSSMManagedInstanceCore` to the role.
- **Instance profile** linking the role to EC2.
- **EC2 instance** (`t2.micro`, Amazon Linux 2023) in the default VPC with the instance profile attached.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `08-ec2-with-ssm` directory:

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

- `instance_id` – ID of the EC2 instance (use for SSM Session Manager).
- `iam_role_name` – Name of the IAM role attached to EC2 for SSM.
- `iam_instance_profile_name` – Name of the IAM instance profile attached to EC2.

Connect in the AWS Console: **EC2 → Instances → Select instance → Connect → Session Manager**. Or use the AWS CLI with the instance ID.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the EC2 instance, instance profile, and IAM role. Only the `t2.micro` instance incurs cost while it runs.

