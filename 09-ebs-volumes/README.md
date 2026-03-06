cat > README.md <<'EOF'
# Lab 09 - EBS Volumes

## What this builds
- EC2 instance
- EBS volume
- Volume attachment to EC2

## Smart words
- EBS (Elastic Block Store): Disk storage used by EC2 instances.
- Block storage: Storage that behaves like a hard drive attached to a computer.
- Volume attachment: Process of connecting an EBS disk to an EC2 instance.

## Cost
- t2.micro EC2 instance
- small gp3 EBS volume

Only a few cents or free if left running.

## Prereqs
- Terraform installed
- AWS CLI configured (`aws configure`)
- Region: eu-central-1

## Run
- terraform init
- terraform plan
- terraform apply or terraform apply -auto-approve (if you are sure)

## After Apply (Prepare the Disk)
Connect to the instance using **SSM Session Manager**.

Check the disks:

lsblk

You should see something similar to:

xvda  → root disk (OS)  
xvdf  → new EBS disk

Format the disk:

sudo mkfs -t xfs /dev/xvdf

Create mount point:

sudo mkdir /data

Mount the disk:

sudo mount /dev/xvdf /data

Verify mount:

df -h

Create test file:

echo "EBS disaster recovery test" | sudo tee /data/test.txt

Check if file exists:

ls /data

Read the file:

cat /data/test.txt

## Create Snapshot
Go to:

AWS Console  
EC2 → Volumes

Select the extra disk and create a snapshot.

Important: the snapshot must contain the following tag:

Key: lab09  
Value: disasterandrecovery

This tag is required because the disaster recovery Terraform code searches the snapshot using this tag.

## Cleanup
- terraform destroy (here the infrastructure will be destroyed completelly but the snapshot will be saved so we can use it with the Disaster Recovery Scenario)

## Disaster Recovery Scenario
Inside this lab there is a child folder:

disaster-recovery-test

This folder contains Terraform code that simulates a recovery scenario.

Steps:

Go into the disaster recovery folder and run Terraform again:

cd disaster-recovery-test

- terraform init  
- terraform plan  
- terraform apply or terraform apply -auto-approve (if you are sure)

Terraform will:

- find the snapshot using the tag
- create a new EC2 instance
- create a new EBS volume from the snapshot
- attach the disk to the new instance

## After Apply (Prepare the Disk)
Connect to the instance using **SSM Session Manager**.

Check the disks:

lsblk

You should see something similar to:

xvda  → root disk (OS)  
xvdf  → new EBS disk

Format the disk:

sudo mkfs -t xfs /dev/xvdf

Create mount point:

sudo mkdir /data

Mount the disk:

sudo mount /dev/xvdf /data

Verify mount:

df -h

Check if file exists:

ls /data

Read the file:

cat /data/test.txt

You get what you saved into the file:

"EBS disaster recovery test"

This means it worked, you recovered the lost data with the help of that snapshot.

## Important Tag Requirement
Both Terraform configurations depend on the same tag:

Key: lab09  
Value: disasterandrecovery

If the snapshot does not contain this tag, the recovery Terraform will not find it.