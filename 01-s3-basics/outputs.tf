output "bucket_name" {
  description = "Name of the S3 lab bucket"
  value       = aws_s3_bucket.primary.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 lab bucket"
  value       = aws_s3_bucket.primary.arn
}

