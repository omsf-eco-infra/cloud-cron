# Cloud Cron To-Do Plan

## Phase 0: Establish repo scaffolding

- [x] Create directories: `modules/scheduled-lambda`, `modules/email-notification`, `modules/sms-notification`, `modules/lambda-container`, `examples/basic`.
- [x] Add shared Terraform version constraints/provider stubs (`versions.tf`), ignore `.terraform.lock.hcl`, and add `.gitignore`.
- [x] Wire `tofu fmt` via pre-commit hook.
- [x] Add Pixi project file with toolchain (terraform/tofu, python for lambdas)
- [x] Verify: run `terraform fmt -recursive`/`tofu fmt` and `terraform validate` at repo root; ensure pre-commit passes; ensure CI bootstrap (if added) passes locally.

## Phase 1: Build scheduled Lambda module (`modules/scheduled-lambda`)
- [ ] Define inputs: `lambda_image_uri`, `schedule_expression`, `sns_topics` (map envvar->ARN), optional `lambda_env`, `timeout`, `memory_size`, `tags`.
- [ ] Create resources: IAM role/policy (CloudWatch Logs + `sns:Publish` to provided ARNs), Lambda from container image, EventBridge rule/target/permission.
- [ ] Outputs: Lambda ARN, execution role ARN, log group name, schedule rule name.
- [ ] Docs: README with usage matching IDEA example.
- [ ] Verify: `terraform validate` in `modules/scheduled-lambda`; example `terraform plan` shows env var wiring and schedule target; run `make validate`/`tflint` if configured.

## Phase 2: Build notification modules

### Phase 2.1: Shared notification container and queueing infra
- [ ] Create single Python codebase (shared package) with entrypoint switching to handler based on env var/routing key; package as one Docker image for Lambda.
- [ ] Terraform: shared container build/publish for notifications; SQS FIFO queue for deduplication between SNS topic and Lambdas; SNS subscription to FIFO SQS with content-based dedup; SQS trigger to Lambda; IAM for SQS poll, logs, SES send, Secrets/SSM read, Twilio access.
- [ ] Inputs per module: `sns_topic_arn`, `fifo_queue_name`/settings, handler selector/env vars; shared tags/log retention.
- [ ] Verify: `terraform validate`; example `plan`; container build succeeds locally; pytest skeleton runs.

### Phase 2.2: Email via SES handler (`modules/email-notification`)
- [ ] Define handler contract: expect message payload with subject/template vars; support optional config set/reply-to; log delivery status.
- [ ] Python code: SES client wrapper; load template (managed via Terraform) and render with variables; handle throttling/retries and DLQ-safe errors.
- [ ] Terraform: SES template creation; Lambda configuration/env (sender, recipients, template name, config set); permissions for SES send + logs; wire to shared container image and handler selection.
- [ ] Tests: pytest with sample SNS/SQS events; stub/moto SES; validate error handling and idempotency.
- [ ] Verify: `terraform validate`; handler unit tests green; document smoke test (publish SNS message to topic -> email delivered/SES sandbox note).

### Phase 2.3: SMS via Twilio handler (`modules/sms-notification`)
- [ ] Define handler contract: expect message payload with body/recipients; support per-message override of to-numbers; log Twilio SID/error.
- [ ] Python code: Twilio REST client wrapper; read SID/auth token from SSM/Secrets; handle rate limits/retries; sanitize phone numbers; DLQ-safe errors.
- [ ] Terraform: Lambda configuration/env (from-number, default recipients, secret ARNs), IAM for Secrets Manager/SSM read + logs; wire to shared container image and handler selection.
- [ ] Tests: pytest with mocked Twilio client; cover success/failure paths and secret fetch.
- [ ] Verify: `terraform validate`; handler unit tests green; document smoke test (publish SNS message to topic -> SMS sent).

## Phase 3: Build Lambda container republish module (`modules/lambda-container`)
- [ ] Inputs: `source_lambda_repo`, `source_lambda_tag`, optional destination repo name, KMS encryption flag.
- [ ] Resources: destination ECR repo, permissions for pull/push, data source for source image digest, replication via `null_resource`/`local-exec` or pull-through cache rule.
- [ ] Outputs: destination `lambda_image_uri` for scheduled module.
- [ ] Verify: `terraform plan` shows repo and replication steps; document manual check (`aws ecr describe-images` for dest tag).

## Phase 4: Example, testing, documentation, release

### Phase 4.1: Example stack and verification (`examples/basic`)
- [ ] Compose: SNS topic feeding a FIFO SQS queue, scheduled-lambda using placeholder client image, notification container Lambda (email/SMS handlers) consuming the queue.
- [ ] Provide variables/defaults and README walkthrough (init, plan, apply, publish test message through SNS->SQS->Lambda).
- [ ] Verify: `terraform fmt/validate` and `terraform plan` in example; document manual SNS publish test and expected outputs.

### Phase 4.2: Testing & CI
- [ ] Add `make test` to run fmt, validate, lint, and Lambda unit tests.
- [ ] Consider lightweight Terratest for scheduled-lambda wiring (guarded to skip apply by default).
- [ ] Add CI workflow (e.g., GitHub Actions) for formatting, validation, and unit tests on PRs.
- [ ] Verify: CI passes on clean tree; local `make test` passes.

### Phase 4.3: Documentation & release
- [ ] Top-level README: module overview, prerequisites (AWS creds, SES/Twilio setup), quickstart commands.
- [ ] Module READMEs: inputs/outputs tables and examples (generated or hand-written).
- [ ] Changelog/semver plan; tag first release after example `plan`/smoke tests documented.
- [ ] Verify: Docs reference real inputs/outputs; walkthrough commands executed once to ensure no typos.
