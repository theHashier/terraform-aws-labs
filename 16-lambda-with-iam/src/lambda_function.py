import json
import os
from datetime import datetime, timezone

import boto3


def handler(event, context):
    s3 = boto3.client("s3")
    resp = s3.list_buckets()

    bucket_names = [b["Name"] for b in resp.get("Buckets", [])]

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(
            {
                "message": "Listed S3 buckets successfully (lab 16).",
                "lab": os.environ.get("LAB_ID", "unknown"),
                "request_id": getattr(context, "aws_request_id", None),
                "bucket_count": len(bucket_names),
                "bucket_names": bucket_names,
                "received_event": event,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        ),
    }

