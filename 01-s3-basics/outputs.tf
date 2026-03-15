output "bucket_name" {
  description = "Name of the S3 bucket created in this lab"
  value       = aws_s3_bucket.lab01_s3.bucket
}
