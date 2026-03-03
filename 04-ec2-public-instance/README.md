# Lab 04 - EC2 public instance

## What this builds
- 1 VPC
- 1 public subnet
- 1 Internet Gateway + route table to the internet
- 1 Security Group (SSH allowed)
- 1 EC2 instance (public IP)

## “Smart words”
- EC2: virtual server in AWS
- VPC: private network in AWS
- Subnet: smaller network inside a VPC
- Internet Gateway: allows internet access for public subnets
- Route table: rules that decide where traffic goes
- Security Group: firewall rules for the instance

## Prereqs
- Terraform installed
- AWS CLI configured
- Region: eu-central-1
- You must have an existing EC2 Key Pair name (for SSH)

## Configure
Create a terraform.tfvars (not committed) with:
key_name = "YOUR_KEYPAIR_NAME"
ssh_cidr = "YOUR_IP/32"

If you don't care about locking SSH to your IP for now, you can use:
ssh_cidr = "0.0.0.0/0"

## Run
- terraform init
- terraform plan
- terraform apply

## Cleanup
- terraform destroy
