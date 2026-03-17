output "bucket_name" {
  description = "Name of the S3 lab bucket"
  value       = aws_s3_bucket.s3.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 lab bucket"
  value       = aws_s3_bucket.s3.arn
}

