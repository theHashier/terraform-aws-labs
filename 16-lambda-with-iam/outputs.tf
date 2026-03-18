output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_role_name" {
  description = "IAM role name used by Lambda"
  value       = aws_iam_role.role_lambda.name
}

output "lambda_role_arn" {
  description = "IAM role ARN used by Lambda"
  value       = aws_iam_role.role_lambda.arn
}

