# Lab 10 – Auto Scaling Group

## What this lab demonstrates

This lab shows how to create an **Auto Scaling Group (ASG)** with a **launch template**: AWS keeps a desired number of EC2 instances running and replaces them if they fail or are terminated. You get one instance by default; the ASG can scale up to two.

## What this lab creates

- **Launch template** (Amazon Linux 2023, t2.micro) used by the ASG to start instances
- **Auto Scaling Group** with min 1, desired 1, max 2 instances across two AZs in the region

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

- **autoscaling_group_name** – Name of the Auto Scaling Group

## Test

After apply, the ASG launches one instance. In **EC2 → Instances** you should see it.

To test replacement: terminate that instance (EC2 → Instances → Terminate, or `aws ec2 terminate-instances --instance-ids <id>`). Within about 30–60 seconds the ASG starts a new one to keep desired capacity.

## Cleanup

```bash
terraform destroy
```

This removes the ASG and launch template; all instances managed by the ASG are terminated. Cost is only for the t2.micro instance(s) while they run.
