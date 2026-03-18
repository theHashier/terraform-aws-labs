terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

locals {
  project_name = "terraform-aws-labs"
  lab_id       = "16-lambda-with-iam"
  environment  = "lab"

  common_tags = {
    Project     = local.project_name
    Lab         = local.lab_id
    Environment = local.environment
    ManagedBy   = "Terraform"
    Name        = local.lab_id
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "role_lambda" {
  name = "${local.lab_id}-role-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_basic_logs" {
  role       = aws_iam_role.role_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "policy_s3_list_buckets" {
  name        = "${local.lab_id}-policy-s3-list-buckets"
  description = "Allow Lambda to list S3 buckets (ListAllMyBuckets)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_list_buckets" {
  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.policy_s3_list_buckets.arn
}

resource "aws_lambda_function" "lambda" {
  function_name = "${local.lab_id}-lambda"
  role          = aws_iam_role.role_lambda.arn

  runtime = "python3.12"
  handler = "lambda_function.handler"
  timeout = 10

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LAB_ID = local.lab_id
    }
  }
}

