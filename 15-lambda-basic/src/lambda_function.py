import json
import os
from datetime import datetime, timezone


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(
            {
                "message": "Hello from Lambda (lab 15)!",
                "lab": os.environ.get("LAB_ID", "unknown"),
                "request_id": getattr(context, "aws_request_id", None),
                "received_event": event,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
        ),
    }

