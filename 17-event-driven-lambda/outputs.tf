output "s3_bucket_name" {
  description = "S3 bucket name created for the lab"
  value       = aws_s3_bucket.s3.bucket
}

output "s3_trigger_prefix" {
  description = "S3 prefix that triggers the Lambda (upload objects under this path)"
  value       = local.trigger_prefix
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_role_name" {
  description = "IAM role name used by Lambda"
  value       = aws_iam_role.role_lambda.name
}

