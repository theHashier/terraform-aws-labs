## Lab 15 – Lambda basics

### Goal

This lab provisions a **basic AWS Lambda function** with Terraform, using the shared bootcamp conventions (locals, `common_tags`, provider `default_tags`). It includes the minimal IAM role required for CloudWatch Logs.

### What this lab creates

- **IAM role** for Lambda execution
- **AWS managed policy attachment**: `AWSLambdaBasicExecutionRole`
- **Lambda function** (Python 3.12) that returns a small JSON response

### Prerequisites

- Terraform installed.
- AWS CLI configured (for example, `aws configure`).
- Default region `eu-central-1` (can be overridden with a variable).

### Usage

From the `15-lambda-basic` directory:

```bash
terraform init
terraform plan
terraform apply
```

To override the region:

```bash
terraform apply -var="aws_region=eu-central-1"
```

### Test (invoke the function)

Get the function name:

```bash
terraform output -raw lambda_function_name
```

Invoke it:

```bash
aws lambda invoke \
  --function-name "$(terraform output -raw lambda_function_name)" \
  --payload '{"hello":"world"}' \
  response.json
cat response.json
```

### Cleanup

```bash
terraform destroy
```

