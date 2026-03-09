# Lab 11 - Application Load Balancer (ALB)

## What this builds
- Application Load Balancer
- Target Group
- Listener (HTTP :80)
- Load balancing across EC2 instances

## Smart words
- Application Load Balancer (ALB): AWS service that distributes HTTP/HTTPS traffic across multiple targets.
- Target Group: A group of resources (EC2 instances) that receive traffic from the load balancer.
- Listener: A rule that checks for incoming traffic on a specific port and forwards it to a target group.

## Cost
Application Load Balancer costs around $0.02 per hour.
Safe for short lab testing.

## Prereqs
- Terraform installed
- AWS CLI configured (`aws configure`)
- Region: eu-central-1

## Run
- terraform init
- terraform plan
- terraform apply or terraform apply -auto-approve (if you are sure)

## Test
After apply, Terraform will output the ALB DNS name.

Open the DNS name in a browser:

http://<alb-dns>

Traffic will be routed to EC2 instances.

## Cleanup
- terraform destroy
