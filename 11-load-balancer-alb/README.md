# Lab 11 – Application Load Balancer (ALB)

## What this lab demonstrates

This lab shows how to put an **Application Load Balancer (ALB)** in front of EC2 instances: a target group, HTTP listener on port 80, and an Auto Scaling Group that runs two instances with Apache. Traffic to the ALB is distributed across the instances. Uses the default VPC.

## What this lab creates

- **Security groups**: one for the ALB (HTTP 80 from 0.0.0.0/0), one for EC2 (HTTP 80 from the ALB only)
- **ALB** with a **target group** and **listener** (HTTP :80 → target group)
- **Launch template** (Amazon Linux 2023, t2.micro, Apache, “Hello from &lt;hostname&gt;” page)
- **Auto Scaling Group** (min 2, desired 2, max 3) registered with the target group

## Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- Default region `eu-central-1` (can be overridden with a variable)
- Default VPC and subnets in the region

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

- **alb_dns_name** – DNS name of the ALB

Open `http://<alb_dns_name>` in a browser. Reload a few times; the “Hello from …” hostname or IP may change as the ALB switches between the two instances.

## Cleanup

```bash
terraform destroy
```

This removes the ALB, target group, listener, ASG, launch template, and security groups. The ALB incurs about $0.02/hour while it exists.
