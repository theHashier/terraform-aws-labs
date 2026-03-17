## Lab 09 – Disaster recovery test

### Goal

This lab runs a **disaster recovery test** by restoring an EBS snapshot into a new volume, attaching it to a fresh EC2 instance, and verifying that the expected data is present. It uses the same shared bootcamp conventions (locals, `common_tags`, provider `default_tags`) so tags and naming are consistent with the other labs.

### What this lab builds

- **EC2 instance**
- **IAM role** and **instance profile** with `AmazonSSMManagedInstanceCore` attached
- **EBS volume** restored from an existing snapshot
- **Volume attachment** from the restored volume to the EC2 instance

### Key concepts

- **EBS Snapshot** – Backup of an EBS volume stored by AWS.
- **Disaster Recovery** – Process of restoring infrastructure and data after a failure.
- **IAM Role** – Identity that gives EC2 permissions to interact with AWS services.
- **Instance Profile** – Container used by AWS to attach an IAM role to EC2 instances.

### Cost

- One `t2.micro` EC2 instance.
- One small `gp3` EBS volume.

Keeping the lab running costs only a small amount (or may fall under the free tier).

### Prerequisites

- Snapshot must exist from the parent lab with tags:
  - Key: `lab09a`
  - Value: `disasterandrecovery`
- Terraform installed.
- AWS CLI configured (`aws configure`).
- Default region `eu-central-1` (can be overridden with `-var="aws_region=..."`).

### Run

From the `09b-disaster-recovery-test` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="aws_region=eu-central-1"
```

After apply, connect to the instance using **SSM Session Manager**.

Check disks:

- `lsblk`

Verify the filesystem exists:

- `sudo file -s /dev/xvdf`

Mount the disk:

- `sudo mkdir /data`
- `sudo mount /dev/xvdf /data`

Check restored file:

- `ls /data`

Read the file:

- `cat /data/test.txt`

Expected output:

- `EBS disaster recovery test`

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the EC2 instance, instance profile, IAM role, and restored EBS volume.
