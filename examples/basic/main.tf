provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = merge(
    { managed_by = "cloudcron" },
    var.tags,
    { project = "cloud-cron-example-basic" },
  )
}

module "lambda_image_build" {
  source = "../../modules/lambda-image-build"

  source_dir      = "${path.module}/lambda"
  repository_name = var.repository_name
  image_tag       = var.image_tag
  platform        = var.platform
  build_args      = var.build_args
  tags            = local.common_tags
}

module "lambda_container_republish" {
  count  = var.enable_republish ? 1 : 0
  source = "../../modules/lambda-container"

  source_lambda_repo          = var.source_lambda_repo
  source_lambda_tag           = var.source_lambda_tag
  source_registry_id          = var.source_registry_id
  destination_repository_name = var.destination_repository_name
  enable_kms_encryption       = var.enable_kms_encryption
  kms_key_arn                 = var.kms_key_arn
  tags                        = local.common_tags
}

locals {
  active_lambda_image_uri = var.enable_republish ? module.lambda_container_republish[0].lambda_image_uri : module.lambda_image_build.image_uri
}

resource "aws_sns_topic" "example_topic" {
  name = "example-topic"
}

module "scheduled_lambda" {
  source = "../../modules/scheduled-lambda"

  lambda_image_uri    = local.active_lambda_image_uri
  schedule_expression = var.schedule_expression
  lambda_name         = var.lambda_name
  sns_topics = {
    EXAMPLE_TOPIC_ARN = aws_sns_topic.example_topic.arn
  }

  tags = local.common_tags
}

output "built_image_uri" {
  description = "Image URI built from examples/basic/lambda."
  value       = module.lambda_image_build.image_uri
}

output "local_image_uri" {
  description = "Image URI from the local republish module when enabled."
  value       = length(module.lambda_container_republish) > 0 ? module.lambda_container_republish[0].lambda_image_uri : null
}

output "active_lambda_image_uri" {
  description = "Image URI to feed into downstream scheduled Lambda modules."
  value       = local.active_lambda_image_uri
}

output "scheduled_lambda_arn" {
  description = "ARN of the scheduled Lambda."
  value       = module.scheduled_lambda.lambda_arn
}
