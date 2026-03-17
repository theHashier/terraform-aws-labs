## Lab 13b – CloudWatch alarms and SNS notifications

### Goal

This lab shows how **CloudWatch alarms send notifications through SNS**. When the EC2 instance’s CPU utilization goes above a threshold, the alarm fires and publishes a message to an SNS topic; the topic has an email subscription, so you receive the alert by email. The alarm is intentionally configured with a **low threshold and short period** so it triggers quickly for testing.

### Architecture

```
EC2 instance (t2.micro)
        │
        │ CPUUtilization metric
        ▼
CloudWatch Alarm (CPU > threshold)
        │
        │ alarm_actions
        ▼
SNS Topic (lab-13b-cloudwatch-alerts)
        │
        │ email subscription
        ▼
Your email inbox
```

- **CloudWatch** collects the `CPUUtilization` metric for the EC2 instance.
- When the metric exceeds the threshold for one evaluation period, the alarm changes to **ALARM**.
- The alarm’s **alarm_actions** point to the SNS topic, so CloudWatch publishes a message to the topic.
- **SNS** delivers that message to all subscribers; with an **email** subscription, AWS sends the notification to your address. You must **confirm the subscription** (click the link in the confirmation email) before notifications are delivered.

### What this lab creates

- **VPC** with one public subnet and internet gateway
- **Security group** (egress only; no SSH/SSM)
- **EC2 instance** (t2.micro, Amazon Linux 2) with a small `user_data` script that starts background CPU load (`yes > /dev/null &`) so the CloudWatch alarm triggers without manual intervention
- **SNS topic** for alarm notifications
- **SNS email subscription** (address from variable)
- **CloudWatch alarm** on `AWS/EC2` → `CPUUtilization`, forwarding to the SNS topic when the alarm state is ALARM

### Alarm configuration

By default, the alarm uses more realistic production-style settings:

- **cpu_alarm_threshold** = 70 (default 70)
- **alarm_period** = 300 seconds (5 minutes)
- **evaluation_periods** = 1 (configured in `main.tf`)

Example override:

```bash
terraform apply \
  -var="email_address=you@example.com" \
  -var="cpu_alarm_threshold=70" \
  -var="alarm_period=300"
```

(You would also set `evaluation_periods = 2` in the `aws_cloudwatch_metric_alarm` resource for a production-style setup.)

### Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- An **email address** you can access (to confirm the SNS subscription and receive test alerts)

### Usage

```bash
terraform init
terraform plan -var="email_address=your@email.com"
terraform apply -var="email_address=your@email.com"
```

**Confirm the SNS subscription:** Check the inbox for `your@email.com` and click the “Confirm subscription” link in the message from AWS SNS. Until you confirm, alarm notifications will not be sent to that address.

**Automatic CPU load:** The EC2 instance runs a `user_data` script at first boot that starts two background processes (`yes > /dev/null &`). These keep the CPU busy so that average utilization stays above the threshold. After the evaluation period, the CloudWatch alarm should transition to ALARM and SNS will send an email to your subscribed address. No need to connect to the instance or run any commands manually.

### Outputs

- **instance_id** – ID of the EC2 instance
- **sns_topic_arn** – ARN of the SNS topic
- **cloudwatch_alarm_name** – Name of the CloudWatch alarm

### Cleanup

```bash
terraform destroy -var="email_address=your@email.com"
```

This removes the VPC, instance, SNS topic, subscription, and CloudWatch alarm.
