# Lab 10 - Auto Scaling Group

## What this builds
- Launch Template
- Auto Scaling Group
- Automatically managed EC2 instances

## Smart words
- Launch Template: Blueprint that defines how EC2 instances should be created (AMI, instance type, etc).
- Auto Scaling Group (ASG): AWS service that automatically creates or terminates EC2 instances based on scaling rules.
- Desired Capacity: Number of EC2 instances AWS tries to keep running.
- Min Size: Minimum number of instances that must always run.
- Max Size: Maximum number of instances AWS can create.

## Cost
Uses t2.micro instances.

Min: 1 instance  
Max: 2 instances  

Only a few cents.

## Prereqs
- Terraform installed
- AWS CLI configured (`aws configure`)
- Region: eu-central-1

## Run
- terraform init
- terraform plan
- terraform apply or terraform apply -auto-approve (if you are sure)

## Test
After apply, AWS will automatically launch one EC2 instance.

Verify:
- Go to EC2 → Instances
- You should see one running instance created by the Auto Scaling Group.

Test Auto Scaling behavior:
1. Terminate the instance manually (EC2 → Instances → Terminate).
2. Wait about 30–60 seconds.
3. A new instance will be launched automatically by the Auto Scaling Group.

CLI test example:
- aws ec2 terminate-instances --instance-ids <instance-id>

AWS will automatically create a replacement instance because the Auto Scaling Group enforces the desired capacity.

## Cleanup
- terraform destroy
