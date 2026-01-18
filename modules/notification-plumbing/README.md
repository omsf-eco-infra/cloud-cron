# Notification Plumbing Module

Shared SNS → SQS FIFO → Lambda wiring for notification handlers. FIFO SQS queues require FIFO SNS topics.

## Usage

```hcl
module "notification_plumbing" {
  source = "./modules/notification-plumbing"

  sns_topic_arn   = aws_sns_topic.example.arn
  fifo_queue_name = "example-notifications.fifo"
}
```

## Inputs

- `sns_topic_arn` (string): SNS topic ARN that feeds the notification queue.
- `fifo_queue_name` (string): Name of the FIFO SQS queue (must end with `.fifo`).
- `content_based_deduplication` (bool): Enable content-based deduplication. Default `true`.
- `visibility_timeout_seconds` (number): Visibility timeout for the queue. Default `30`.
- `message_retention_seconds` (number): Retention period for messages. Default `1209600`.
- `create_dlq` (bool): Whether to create a DLQ. Default `true`.
- `max_receive_count` (number): Receives before moving to DLQ. Default `5`.
- `tags` (map(string)): Tags applied to resources.

## Outputs

- `queue_arn`: ARN of the notification queue.
- `queue_url`: URL of the notification queue.
- `queue_name`: Name of the notification queue.
- `dlq_arn`: ARN of the DLQ (if created).
- `subscription_arn`: ARN of the SNS subscription.
- `lambda_sqs_policy_json`: IAM policy JSON for Lambda SQS permissions.
