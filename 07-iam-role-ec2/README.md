# Lab 07 - IAM Role for EC2

## What this builds
- IAM Role
- IAM Policy
- Instance Profile
- EC2 instance with IAM role attached

## Smart words
- IAM: Identity and Access Management service used to control permissions in AWS.
- IAM Role: A set of permissions that AWS services can assume temporarily.
- Policy: A JSON document that defines allowed or denied actions.
- Instance Profile: A container that allows an IAM Role to be attached to an EC2 instance.

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
