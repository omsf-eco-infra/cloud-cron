locals {
  repository_name = coalesce(var.repository_name, "${basename(var.source_dir)}-source")
  tags            = merge({ managed_by = "cloudcron" }, var.tags)
  build_args_list = [for k, v in var.build_args : format("--build-arg %s=%s", k, v)]
  build_args_str  = length(local.build_args_list) == 0 ? "" : "${join(" ", local.build_args_list)} "
  build_context_hash = sha1(join("", [
    for file_path in fileset(var.source_dir, "**") :
    filesha256("${var.source_dir}/${file_path}")
  ]))
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ecr_repository" "lambda_image" {
  name                 = local.repository_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.lambda_image.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "null_resource" "build_and_push" {
  triggers = {
    image_tag       = var.image_tag
    repository_url  = aws_ecr_repository.lambda_image.repository_url
    build_args      = jsonencode(var.build_args)
    platform        = var.platform
    build_context   = local.build_context_hash
    repository_name = aws_ecr_repository.lambda_image.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-EOC
      set -euo pipefail
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      docker buildx build --platform ${var.platform} ${local.build_args_str}-t ${aws_ecr_repository.lambda_image.repository_url}:${var.image_tag} ${var.source_dir}
      docker push ${aws_ecr_repository.lambda_image.repository_url}:${var.image_tag}
    EOC
  }

  depends_on = [
    aws_ecr_lifecycle_policy.cleanup,
  ]
}
