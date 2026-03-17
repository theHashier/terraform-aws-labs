## Lab 14 – EventBridge automation with S3 and SNS

### Goal

This lab shows how **Amazon EventBridge can react to events from S3 and fan them out through SNS**. When an object is created in an S3 bucket, EventBridge matches the event against a rule and forwards it to an SNS topic, which sends an **email notification**.

It focuses on the **event-driven wiring** between services (S3 → EventBridge → SNS) rather than any complex compute.

### Architecture

```
S3 bucket (PutObject)
        │
        │ Object Created event
        ▼
EventBridge rule (filter on bucket)
        │
        │ target
        ▼
SNS topic (lab-14-eventbridge-notifications)
        │
        │ email subscription
        ▼
Your email inbox
```

- **S3** is the event source. When you upload an object, AWS emits an event.
- **EventBridge** receives the event, matches it against the rule with a filter on the specific S3 bucket name, and sends matching events to the target.
- **SNS** is the target. EventBridge publishes the event to the SNS topic, which then sends an email to subscribed addresses.

### What this lab creates

- **S3 bucket** (`bucket_prefix` based) used as the event source
- **Bucket public access block** (to keep the bucket private)
- **SNS topic** for notifications
- **SNS email subscription** (address from variable `email_address`)
- **EventBridge rule** that matches `Object Created` events from the lab’s S3 bucket
- **EventBridge target** that routes matched events to the SNS topic
- **SNS topic policy** that allows **EventBridge** to publish to the SNS topic for this rule

### Prerequisites

- Terraform installed
- AWS CLI configured (e.g. `aws configure`)
- An **email address** you can access (to confirm the SNS subscription and receive test alerts)
- **S3 events to EventBridge enabled** in the AWS account/region you are using:
  - In the AWS console, go to **S3 → Settings → Event notifications** (or similar section).
  - Enable **“Send notifications to Amazon EventBridge”** for this region so that S3 object events are delivered to EventBridge.
  - Without this, the EventBridge rule in this lab will never receive the S3 events.

Default region is `eu-central-1`, but you can override it with `-var="aws_region=..."`.

### Usage

Initialize and apply:

```bash
terraform init
terraform plan \
  -var="email_address=you@example.com"
terraform apply \
  -var="email_address=you@example.com"
```

After `apply` completes, check the outputs to see the **bucket name** and **SNS topic ARN**:

```bash
terraform output
```

### Confirm the SNS subscription

- Check the inbox for `you@example.com` and look for an email from **AWS Notifications** (SNS).
- Click **“Confirm subscription”** in the email.
- Until you confirm, EventBridge-delivered notifications will not be sent to that address.

### Generate events

Upload an object to the lab bucket. Replace `<bucket_name>` with the value from `terraform output bucket_name`:

```bash
aws s3 cp test-file.txt s3://<bucket_name>/test-file.txt
```

You can also upload from the AWS Console or create multiple files; each PutObject should generate a matching event.

Within a short time after each upload, EventBridge should route the event to SNS and you should receive an **email notification**.

### Outputs

- **bucket_name** – Name of the S3 bucket that emits events
- **sns_topic_arn** – ARN of the SNS topic that receives EventBridge events
- **eventbridge_rule_arn** – ARN of the EventBridge rule

### Cleanup

Before destroying, empty the S3 bucket to avoid errors (either via AWS Console or CLI). For example:

```bash
aws s3 rm s3://<bucket_name> --recursive
```

Then destroy the stack:

```bash
terraform destroy \
  -var="email_address=you@example.com"
```

This removes the bucket, SNS topic (and subscription), EventBridge rule, and related resources.

