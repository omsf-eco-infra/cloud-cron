# Use Email Notifications

The LambdaCron root module creates the scheduled Lambda and shared SNS topic, but it does not create notification channels. Use `email-notification` to send selected `result_type` values through Amazon SES.

## When to Use
- You want SES email notifications for one or more LambdaCron `result_type` values.
- You already have, or can provide, a notification-handler container image.

## Before You Begin
- Complete SES setup in [Set Up SES Prerequisites](set-up-ses.md).
- Verify your SES sender identity in the same AWS region as your notifier Lambda.
- If your account is in SES sandbox mode, verify recipient addresses too.
- Create your subject/text/html template files.

## Inputs to Provide
- `sns_topic_arn` from your LambdaCron stack output.
- `lambda_image_uri` for the notification handler container.
- `fifo_queue_name` ending with `.fifo`.
- `sender`, `recipients`, and optional `reply_to`.
- `subject_template_file`, `text_template_file`, and `html_template_file`.
- Optional runtime/routing settings such as `result_types`, `lambda_name`, `batch_size`, and `tags`.

## Steps

### 1. Create email templates

```text
# templates/email-subject.txt
[{{ result_type }}] LambdaCron notification
```

```text
# templates/email-body.txt
Result type: {{ result_type }}
Message: {{ message }}
```

```html
<!-- templates/email-body.html -->
<h2>LambdaCron notification</h2>
<p><strong>Result type:</strong> {{ result_type }}</p>
<p><strong>Message:</strong> {{ message }}</p>
```

### 2. (Optional) Republish the notification image

```hcl
module "notification_image_republish" {
  source = "../../modules/lambda-image-republish"

  source_lambda_repo = "public.ecr.aws/i9p4w7k9/lambdacron-notifications"
  source_lambda_tag  = "latest"
}
```

### 3. Add the `email-notification` module

```hcl
module "email_notification" {
  source = "../../modules/email-notification"

  sns_topic_arn    = module.lambdacron.sns_topic_arn
  fifo_queue_name  = "lambdacron-email.fifo"
  lambda_image_uri = module.notification_image_republish.lambda_image_uri_with_digest

  result_types = ["example", "ERROR"]

  sender     = var.email_sender
  recipients = var.email_recipients
  reply_to   = var.email_reply_to

  subject_template_file = "${path.module}/templates/email-subject.txt"
  text_template_file    = "${path.module}/templates/email-body.txt"
  html_template_file    = "${path.module}/templates/email-body.html"

  tags = local.common_tags
}
```

### 4. Plan and apply

```bash
tofu plan
tofu apply
```

## Validation
- Publish a test message with a `result_type` value included in `result_types`:

```bash
aws sns publish \
  --topic-arn "$(tofu output -raw sns_topic_arn)" \
  --message '{"message":"Email notification smoke test"}' \
  --message-attributes '{"result_type":{"DataType":"String","StringValue":"example"}}' \
  --message-group-id "email-smoke-test"
```

- Confirm the `email_notification` Lambda is invoked from SQS.
- Confirm successful `ses:SendEmail` events in CloudWatch Logs.
- Confirm the email is received.
