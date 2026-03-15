# Lab 09 – EBS volumes

## What this lab demonstrates

This lab shows how to create an **EBS volume** and **attach it to an EC2 instance** with Terraform. The instance has SSM so you can connect without SSH. You then format and mount the disk, create a snapshot, and use the `disaster-recovery-test` subfolder to recover from that snapshot.

## What this lab creates

- **IAM role** with `AmazonSSMManagedInstanceCore` and **instance profile**
- **EC2 instance** (t2.micro, Amazon Linux 2023) in the default VPC
- **EBS volume** (8 GiB, gp3) in the same AZ as the instance
- **Volume attachment** at `/dev/xvdf`

## Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- Default region `eu-central-1` (can be overridden with a variable)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="region=eu-central-1"
```

## Outputs

- **instance_id** – ID of the EC2 instance (connect via SSM Session Manager)
- **volume_id** – ID of the EBS volume

## After apply – prepare the disk

Connect via **EC2 → Connect → Session Manager**, then:

```bash
lsblk                    # see xvda (root) and xvdf (new volume)
sudo mkfs -t xfs /dev/xvdf
sudo mkdir /data
sudo mount /dev/xvdf /data
df -h
echo "EBS disaster recovery test" | sudo tee /data/test.txt
ls /data && cat /data/test.txt
```

## Create snapshot (for disaster recovery)

In the AWS Console: **EC2 → Volumes** → select the extra disk → **Create snapshot**.

Add this tag so the disaster-recovery Terraform can find it:

- **Key:** `lab09`
- **Value:** `disasterandrecovery`

## Cleanup

```bash
terraform destroy
```

This removes the instance and volume. Snapshots you created are kept.

## Disaster recovery scenario

The subfolder **`disaster-recovery-test/`** contains Terraform that:

- Finds the snapshot by tag `lab09 = disasterandrecovery`
- Creates a new EC2 instance and EBS volume from that snapshot
- Attaches the volume to the new instance

After running it, connect via SSM, mount `/dev/xvdf` at `/data`, and confirm `cat /data/test.txt` shows `EBS disaster recovery test`. Both this lab and the disaster-recovery code rely on the same tag: **Key `lab09`, Value `disasterandrecovery`**.
