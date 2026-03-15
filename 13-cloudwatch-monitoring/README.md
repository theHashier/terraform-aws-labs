# Lab 13 – CloudWatch CPU Monitoring

## What this lab demonstrates

This lab shows how to **monitor EC2 CPU usage with CloudWatch alarms**. Terraform creates a minimal EC2 instance and a CloudWatch alarm that triggers when the instance’s CPU utilization goes above a set threshold. Everything runs in a single, self-contained stack.

## What this lab creates

- **VPC** with one public subnet and internet gateway (minimal network)
- **Security group** with no inbound rules (no SSH, no SSM)
- **EC2 instance**: t2.micro, latest Amazon Linux 2 AMI
- **CloudWatch alarm** for `CPUUtilization`:
  - Triggers when CPU &gt; 70%
  - 2 evaluation periods (5 minutes each)
  - Monitors the EC2 instance created in this lab

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

- **instance_id** – ID of the EC2 instance
- **instance_public_ip** – Public IP of the EC2 instance
- **cloudwatch_alarm_name** – Name of the CloudWatch CPU alarm

You can watch the alarm in the AWS Console under CloudWatch → Alarms. To generate load and test the alarm, use another lab or connect via SSM if you add it later.

## Cleanup

```bash
terraform destroy
```

This removes the VPC, instance, and alarm.
