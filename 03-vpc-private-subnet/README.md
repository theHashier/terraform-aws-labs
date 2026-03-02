# Lab 03 - VPC with private subnet (no NAT)

## What this builds
- 1 VPC
- 1 Internet Gateway (for the public subnet only)
- 1 public subnet
- 1 private subnet (no internet route)
- 2 route tables (public + private)
- 1 S3 Gateway VPC Endpoint (so private subnet can reach S3 without internet)

## “Smart words”
- Public subnet: subnet that can route to the internet via an Internet Gateway (IGW)
- Private subnet: subnet that has no route to the internet
- Route table: rules that decide where traffic goes (local / IGW / etc.)
- VPC Endpoint (S3 Gateway): private connection to S3 without NAT/Internet

## Prereqs
- Terraform installed
- AWS CLI configured (`aws configure`)
- Region: eu-central-1 or you region.

## Cost safety
- No NAT Gateway (to avoid hourly charges)
- S3 Gateway endpoint is typically free (you pay only for S3 usage)

## Run
- terraform init
- terraform plan
- terraform apply or terraform apply -auto-approve(if you are sure) 

## Cleanup
- terraform destroy
