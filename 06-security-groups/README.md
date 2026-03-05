# Lab 06 - Security Groups

## What this builds
- VPC
- Security Group with SSH, HTTP, and HTTPS access

## Smart words
- Security Group: A virtual firewall attached to AWS resources. It controls which traffic is allowed in or out.
- Firewall: A system that filters network traffic. It decides which connections are allowed.
- Port: A numbered network door used by services. Examples: 22 → SSH (remote login to Linux), 80 → HTTP (web traffic), 443 → HTTPS (secure web traffic)
- SSH: Secure Shell. A protocol used to remotely log into Linux servers.
- Stateful: Security Groups are stateful. If traffic is allowed IN, the response is automatically allowed OUT.

## Cost
No running compute resources. Cost is effectively $0.

## Prereqs
- Terraform installed
- AWS CLI configured (`aws configure`)
- Region: eu-central-1

## Run
- terraform init  
- terraform plan  
- terraform apply or terraform apply -auto-approve (if you are sure)

## Cleanup
- terraform destroy