# Use a test URL

## When to Use
- You want to verify that your deployment is working, but don't want to wait for the cron job to trigger naturally.

This is a live test that everything except the cron job is working. It will run the lambda, and then trigger any notifications that are configured.

We recommend removing the test URL after testing. Otherwise, someone could accidentally trigger the Lambda function by visiting the test URL, which could lead to annoying and unnecessary notifications.

## Steps
- Set the `create_test_url` variable to `true` in your deployment configuration (when using either the root module or the scheduled-lambda module).
- Deploy your infrastructure.
- The test URL will be in the output variable `scheduled_lambda_test_url`. You can just curl that URL to trigger the Lambda function immediately.
- One-liner after deploy: `curl $(tofu output -raw scheduled_lambda_test_url)`
- After testing, set `create_test_url` back to `false` and redeploy to remove the test URL from your infrastructure.

