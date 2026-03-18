import json
import os
from datetime import datetime, timezone

import boto3


def handler(event, context):
    records = event.get("Records", []) if isinstance(event, dict) else []
    if not records:
        print("No S3 Records found in event")
        return {
            "statusCode": 400,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(
                {
                    "message": "No S3 Records found in event.",
                    "lab": os.environ.get("LAB_ID", "unknown"),
                    "request_id": getattr(context, "aws_request_id", None),
                    "received_event": event,
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                }
            ),
        }

    record = records[0]
    bucket = record.get("s3", {}).get("bucket", {}).get("name")
    key = record.get("s3", {}).get("object", {}).get("key")
    size = record.get("s3", {}).get("object", {}).get("size")
    etag = record.get("s3", {}).get("object", {}).get("eTag")

    if not bucket or not key:
        print("Invalid S3 event shape (missing bucket/key)")
        return {
            "statusCode": 400,
            "headers": {"content-type": "application/json"},
            "body": json.dumps(
                {
                    "message": "Invalid S3 event shape (missing bucket/key).",
                    "lab": os.environ.get("LAB_ID", "unknown"),
                    "request_id": getattr(context, "aws_request_id", None),
                    "received_event": event,
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                }
            ),
        }

    print(f"Uploaded object event: s3://{bucket}/{key}")
    print(
        json.dumps(
            {
                "bucket": bucket,
                "key": key,
                "size": size,
                "etag": etag,
                "request_id": getattr(context, "aws_request_id", None),
            }
        )
    )

    s3 = boto3.client("s3")
    obj = s3.get_object(Bucket=bucket, Key=key)
    body = obj["Body"].read().decode("utf-8", errors="replace")

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(
            {
                "message": "S3 event processed successfully (lab 17).",
                "lab": os.environ.get("LAB_ID", "unknown"),
                "request_id": getattr(context, "aws_request_id", None),
                "bucket": bucket,
                "key": key,
                "size": size,
                "etag": etag,
                "object_preview": body[:500],
                "trigger_prefix": os.environ.get("TRIGGER_PREFIX"),
                "received_event": event,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        ),
    }

