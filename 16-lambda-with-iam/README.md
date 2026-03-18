## Lab 16 - Lambda with IAM (S3 List Buckets)

### Goal
Deploy a Python Lambda function and give it **only** the IAM permission it needs to call `s3:ListAllMyBuckets`.

### What this lab creates
- **IAM role** for Lambda execution
- **CloudWatch Logs** permissions (AWS managed policy)
- **Custom IAM policy** allowing S3 list buckets
- **Lambda function** deployed from `src/` (zipped by Terraform)

### Prerequisites
- Terraform `>= 1.6`
- AWS credentials configured (same as other labs)

### Usage
```bash
terraform init
terraform fmt
terraform validate
terraform apply
```

### Test (invoke)
From this lab directory:

```bash
aws lambda invoke \
  --function-name "$(terraform output -raw lambda_function_name)" \
  --payload '{"hello":"world"}' \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json
```

### Outputs
- `lambda_function_name`
- `lambda_role_name`
- `lambda_role_arn`

### Cleanup
```bash
terraform destroy
```

