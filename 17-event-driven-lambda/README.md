## Lab 17 - Event-driven Lambda (S3 Trigger)

### Goal
Create an S3 bucket and configure **S3 ObjectCreated events** to trigger a Lambda. The Lambda reads the uploaded object content, using IAM permissions scoped to **only** the bucket and a specific prefix.

### What this lab creates
- **S3 bucket** (randomized with `bucket_prefix`)
- **S3 → Lambda notification** for `s3:ObjectCreated:*` events (prefix-filtered)
- **IAM role** for Lambda execution
- **CloudWatch Logs** permissions (AWS managed policy)
- **Custom IAM policy**: `s3:GetObject` and `s3:ListBucket` scoped to this bucket + `uploads/` prefix
- **Lambda function** deployed from `src/` (zipped by Terraform)

### Usage
```bash
terraform init
terraform fmt
terraform validate
terraform apply
```

### Test (event-driven)
After `terraform apply`, create a local file and upload it under the trigger prefix:

```bash
echo "hello from lab 17" > some-file.txt

aws s3 cp ./some-file.txt "s3://$(terraform output -raw s3_bucket_name)/$(terraform output -raw s3_trigger_prefix)some-file.txt"
```

Then tail the Lambda logs:

```bash
aws logs tail "/aws/lambda/$(terraform output -raw lambda_function_name)" --follow
```

You should see a line like:
- `Uploaded object event: s3://<bucket>/<key>`

### Outputs
- `s3_bucket_name`
- `s3_trigger_prefix`
- `lambda_function_name`
- `lambda_role_name`

### Cleanup
```bash
terraform destroy
```

