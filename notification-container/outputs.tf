output "repository_arn" {
  description = "ARN of the public ECR repository."
  value       = module.notification_image.repository_arn
}

output "repository_uri" {
  description = "URI of the public ECR repository."
  value       = module.notification_image.repository_uri
}

output "image_uri" {
  description = "Full image URI including the tag."
  value       = module.notification_image.image_uri
}
