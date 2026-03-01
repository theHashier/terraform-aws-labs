# Lab 02 - VPC basic

## What this builds
- 1 VPC
- 1 public subnet
- 1 Internet Gateway
- 1 route table + default route to the IGW
- route table association to the public subnet

## “Smart words”
- VPC: your private network in AWS
- CIDR: IP range for the network (example: 10.0.0.0/16)
- Subnet: smaller network inside the VPC (example: 10.0.1.0/24)
- IGW (Internet Gateway): lets the VPC reach the internet
- Route table: rules for where traffic goes (0.0.0.0/0 = “any internet address”)

## Cost
- This lab is basically free (no NAT Gateway)

## Prereqs
- Terraform installed
- AWS CLI configured
- Region: eu-central-1

## Run
terraform init
terraform plan
terraform apply

## Cleanup
terraform destroy
