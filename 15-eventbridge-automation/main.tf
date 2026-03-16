terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

########################
# S3 bucket (event source)
########################

resource "aws_s3_bucket" "events" {
  bucket_prefix = "lab15-eventbridge-automation-"

  tags = {
    Name = "lab15-eventbridge-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "events" {
  bucket = aws_s3_bucket.events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# SNS topic (notification target)
########################

resource "aws_sns_topic" "notifications" {
  name = "lab15-eventbridge-notifications"

  tags = {
    Name = "lab15-eventbridge-notifications"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.email_address
}

########################
# EventBridge rule & target
########################

resource "aws_cloudwatch_event_rule" "s3_put_object" {
  name        = "lab15-s3-putobject-rule"
  description = "Trigger on S3 PutObject events for the lab15 bucket"

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.events.bucket]
      },
      "object" : {
        "size" : [{
          "numeric" : [">", 0]
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.s3_put_object.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.notifications.arn
}

########################
# EventBridge -> SNS permission
########################

data "aws_iam_policy_document" "sns_from_eventbridge" {
  statement {
    sid    = "AllowEventBridgeToPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sns:Publish"]

    resources = [aws_sns_topic.notifications.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.s3_put_object.arn]
    }
  }
}

resource "aws_sns_topic_policy" "sns_from_eventbridge" {
  arn    = aws_sns_topic.notifications.arn
  policy = data.aws_iam_policy_document.sns_from_eventbridge.json
}

