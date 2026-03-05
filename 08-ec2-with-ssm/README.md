# Lab 08 - EC2 with SSM

## What this builds
- IAM Role
- IAM Policy attachment (AmazonSSMManagedInstanceCore)
- Instance Profile
- EC2 instance accessible through Systems Manager

## Smart words
- Systems Manager (SSM): AWS service used to manage EC2 instances.
- Session Manager: Feature that allows shell access to instances without SSH.
- IAM Role: Identity that gives EC2 permissions to interact with AWS services.

## Cost
Only a t2.micro EC2 instance → a few cents or free if left running.

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
