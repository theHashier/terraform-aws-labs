## Lab 12 – ALB health checks

### Goal

This lab shows how an **Application Load Balancer (ALB) health check** works. The ALB sends periodic HTTP requests to the target. If the instance responds with 200, it is **healthy** and receives traffic; if it stops responding, it becomes **unhealthy** and the ALB returns 503. You simulate a failure by stopping Apache and watch the target go unhealthy, then recover it.

### What this lab creates

- **VPC** with two public subnets, Internet Gateway, and route table
- **Security groups** for the ALB (HTTP 80 from internet) and EC2 (HTTP 80 from ALB only)
- **IAM role** with SSM (instance profile) for EC2
- **EC2 instance** (t2.micro, Amazon Linux 2023, Apache) serving `"healthy"` at `/`
- **ALB** with **target group** (health check: path `/`, interval 30s, healthy 2, unhealthy 2, matcher 200), **listener** (HTTP :80), and target group attachment

Traffic: **User → ALB → Target Group → EC2**. The ALB health-checks `http://EC2:80/`.

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `12-health-checks` directory:

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

- `alb_dns_name` – DNS name of the ALB.
- `alb_http_url` – Full HTTP URL for the ALB (recommended).

Open the URL from `alb_http_url` in a browser; you should see `"healthy"` (instance is healthy).

### Health check experiment

1. **Connect** to the EC2 instance via **EC2 → Connect → Session Manager**. Run `curl localhost` → `"healthy"`.
2. **Simulate failure:** `sudo systemctl stop httpd`. The app is down.
3. **Observe:** In **EC2 → Target Groups → Targets**, the target becomes **unhealthy** after a short time. Opening the ALB URL returns **503 Service Temporarily Unavailable**.
4. **Recover:** `sudo systemctl start httpd`. After a few health checks the target is **healthy** again and the site works.

This illustrates: **application crash → ALB detects failure → instance marked unhealthy → traffic stopped**. Clean up when done: `terraform destroy`.
