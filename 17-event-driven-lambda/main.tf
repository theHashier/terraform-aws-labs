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
  lab_id       = "17-event-driven-lambda"
  environment  = "lab"

  trigger_prefix = "uploads/"

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

resource "aws_s3_bucket" "s3" {
  bucket_prefix = "${local.lab_id}-"
  force_destroy = true
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

resource "aws_iam_policy" "policy_s3_get_object" {
  name        = "${local.lab_id}-policy-s3-get-object"
  description = "Allow Lambda to read objects created under the trigger prefix"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucketPrefix"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.s3.arn
        Condition = {
          StringLike = {
            "s3:prefix" = "${local.trigger_prefix}*"
          }
        }
      },
      {
        Sid    = "GetObjectsUnderPrefix"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.s3.arn}/${local.trigger_prefix}*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_get_object" {
  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.policy_s3_get_object.arn
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
      LAB_ID         = local.lab_id
      TRIGGER_PREFIX = local.trigger_prefix
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3.arn
}

resource "aws_s3_bucket_notification" "notif_lambda" {
  bucket = aws_s3_bucket.s3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = local.trigger_prefix
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

