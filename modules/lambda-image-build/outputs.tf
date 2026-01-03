output "image_uri" {
  description = "URI of the built Lambda image."
  value       = "${aws_ecr_repository.lambda_image.repository_url}:${var.image_tag}"
}

output "image_uri_with_digest" {
  description = "Digest-pinned URI of the built Lambda image."
  value       = "${aws_ecr_repository.lambda_image.repository_url}@${data.aws_ecr_image.built.image_digest}"
}

output "repository_arn" {
  description = "ARN of the created ECR repository."
  value       = aws_ecr_repository.lambda_image.arn
}

output "repository_url" {
  description = "URL of the created ECR repository."
  value       = aws_ecr_repository.lambda_image.repository_url
}
