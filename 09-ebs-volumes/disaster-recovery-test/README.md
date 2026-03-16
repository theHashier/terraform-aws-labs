# Disaster Recovery Test

## What this builds
- EC2 instance
- IAM Role
- IAM Policy attachment (AmazonSSMManagedInstanceCore)
- Instance Profile
- EBS volume restored from snapshot
- Volume attachment to EC2

## Smart words
- EBS Snapshot: Backup of an EBS volume stored by AWS.
- Disaster Recovery: Process of restoring infrastructure and data after a failure.
- IAM Role: Identity that gives EC2 permissions to interact with AWS services.
- Instance Profile: Container used by AWS to attach an IAM role to EC2.

## Cost
- t2.micro EC2 instance
- small gp3 EBS volume

Only a few cents or free if left running.

## Prereqs
- Snapshot must exist from the parent lab
- Snapshot tag must be:

  - Key: `lab09`  
  - Value: `disasterandrecovery`

- Terraform installed
- AWS CLI configured (`aws configure`)
- Default region `eu-central-1` (can be overridden with `-var="region=..."`)

## Run

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="region=eu-central-1"
```

After apply connect to the instance using **SSM Session Manager**.

Check disks:

- lsblk

Verify the filesystem exists:

- sudo file -s /dev/xvdf

Mount the disk:

- sudo mkdir /data
- sudo mount /dev/xvdf /data

Check restored file:

- ls /data

Read the file:

- cat /data/test.txt

Expected output:

- "EBS disaster recovery test"

## Cleanup
- terraform destroy