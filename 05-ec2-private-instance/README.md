# Lab 05 - EC2 private instance

## What this builds
- 1 VPC
- 1 public subnet
- 1 private subnet
- 1 EC2 instance inside the private subnet

## Smart words
- VPC: Virtual Private Cloud. A private network inside AWS.
- Subnet: A smaller network inside the VPC.
- Private Subnet: A subnet that has NO route to the internet.
- Private EC2: An EC2 instance without public IP that only other resources inside the VPC can reach.

## Why this exists
In real production systems we never expose everything to the internet.

Typical architecture:

Internet
   |
Public EC2 (web server)
   |
Private EC2 (database / backend)

Private resources are protected from direct internet access.

## Cost
Only one t2.micro instance for free.

## Run
- terraform init
- terraform plan
- terraform apply

## Cleanup
- terraform destroy
