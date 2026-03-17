terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  project_name = "terraform-aws-labs"
  lab_id       = "lab-14-eventbridge-automation"
  environment  = "lab"

  common_tags = {
    Name        = local.lab_id
    Project     = local.project_name
    Lab         = local.lab_id
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

########################
# S3 bucket (event source)
########################

resource "aws_s3_bucket" "s3_events" {
  bucket_prefix = "lab-14-eventbridge-automation-"
}

resource "aws_s3_bucket_public_access_block" "s3_events_pab" {
  bucket = aws_s3_bucket.s3_events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# SNS topic (notification target)
########################

resource "aws_sns_topic" "sns_notifications" {
  name = "lab-14-eventbridge-notifications"
}

resource "aws_sns_topic_subscription" "sub_email" {
  topic_arn = aws_sns_topic.sns_notifications.arn
  protocol  = "email"
  endpoint  = var.email_address
}

########################
# EventBridge rule & target
########################

resource "aws_cloudwatch_event_rule" "rule_s3_put_object" {
  name        = "lab-14-s3-putobject-rule"
  description = "Trigger on S3 PutObject events for the lab 14 bucket"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.s3_events.bucket]
      },
      "object" : {
        "size" : [{
          "numeric" : [">", 0]
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "target_sns" {
  rule      = aws_cloudwatch_event_rule.rule_s3_put_object.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.sns_notifications.arn
}

########################
# EventBridge -> SNS permission
########################

data "aws_iam_policy_document" "policy_sns_from_events" {
  statement {
    sid    = "AllowEventBridgeToPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sns:Publish"]

    resources = [aws_sns_topic.sns_notifications.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.rule_s3_put_object.arn]
    }
  }
}

resource "aws_sns_topic_policy" "sns_from_events" {
  arn    = aws_sns_topic.sns_notifications.arn
  policy = data.aws_iam_policy_document.policy_sns_from_events.json
}

