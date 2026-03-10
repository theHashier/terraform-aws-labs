# Lab 12 – ALB Health Checks

## What this lab is about
In this lab you will learn how an Application Load Balancer (ALB) checks if a server is healthy. The load balancer periodically sends a request to the EC2 instance. If the server responds correctly it is marked **healthy**. If it does not respond it becomes **unhealthy** and the load balancer stops sending traffic to it. This is a fundamental concept used in real production systems.

## What this lab creates
Terraform builds the following infrastructure:
- VPC
- Public Subnets
- Internet Gateway
- Application Load Balancer
- Target Group with Health Checks
- EC2 instance running Apache
- IAM role for SSM access

Traffic flow:

User → ALB → Target Group → EC2

The ALB constantly checks:

http://EC2:80/

## Prerequisites
You need:
- Terraform installed
- AWS CLI configured
- AWS region set to eu-central-1

Configure AWS if needed:

aws configure

## Step 1 – Deploy the infrastructure
Initialize Terraform:

- terraform init

Check what will be created:

- terraform plan

Create the infrastructure:

- terraform apply or terraform apply -auto-approve (if you are sure)
 
After deployment Terraform outputs the ALB DNS address.

Open it in your browser:

http://<alb_dns>

You should see:

"healthy"

This means the load balancer sees the instance as **healthy**.

## Step 2 – Connect to the EC2 instance
Use SSM Session Manager.

AWS Console path:

EC2 → Instance → Connect → Session Manager

This opens a shell on the instance.

## Step 3 – Verify the web server
Inside the instance run:

- curl localhost

Expected output:

"healthy"

## Step 4 – Simulate a failure
Stop the web server:

- sudo systemctl stop httpd

Now the application is down.

## Step 5 – Observe the health check
Go to:

EC2 → Target Groups → Targets

After a short time the instance will become:

"unhealthy"

The load balancer detected that the server stopped responding.

Opening the ALB URL in the browser will now show:

503 Service Temporarily Unavailable

## Step 6 – Recover the instance
Restart Apache:

- sudo systemctl start httpd

After several health checks the instance will become:

"healthy"

The website will work again.

## What you learned
You simulated a real production scenario:

Application crash  
↓  
Load balancer detects failure  
↓  
Instance marked unhealthy  
↓  
Traffic stops being routed to it

This is the basis for high availability systems.

## Cleanup
Destroy all resources:

- terraform destroy

Always clean up to avoid AWS costs.