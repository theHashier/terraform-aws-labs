## Lab 09a – EBS volumes

### Goal

This lab shows how to create an **EBS volume** and **attach it to an EC2 instance** with Terraform, using the shared bootcamp conventions (locals, `common_tags`, provider `default_tags`). The instance uses SSM so you can connect without SSH. You will format and mount the disk, write a test file, and then create a snapshot that is used by lab **09b** for a disaster recovery restore test.

### What this lab creates

- **IAM role** with `AmazonSSMManagedInstanceCore` and an **instance profile**
- **EC2 instance** (`t2.micro`, Amazon Linux 2023) in the default VPC
- **EBS volume** (8 GiB, `gp3`) in the same AZ as the instance
- **Volume attachment** at `/dev/xvdf`

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `09a-ebs-volumes` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="aws_region=eu-central-1"
```

### Outputs

- `instance_id` – ID of the EC2 instance (connect via SSM Session Manager).
- `volume_id` – ID of the EBS volume.

### After apply – prepare the disk

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

### Create snapshot (for disaster recovery)

In the AWS Console: **EC2 → Volumes** → select the extra disk → **Create snapshot**.

Add this tag so lab **09b** can find it:

- **Key:** `lab09a`
- **Value:** `disasterandrecovery`

### Disaster recovery lab

Lab **`09b-disaster-recovery-test/`** restores the snapshot found by the tag above, attaches it to a new EC2 instance, and verifies the file at `/data/test.txt`.

### Cleanup

```bash
terraform destroy
```

Destroying the lab removes the instance and volume. Snapshots you created are kept.
