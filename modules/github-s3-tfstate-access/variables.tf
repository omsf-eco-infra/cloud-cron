variable "role_name" {
  description = "IAM role name to attach the backend access policy to."
  type        = string

  validation {
    condition     = length(trimspace(var.role_name)) > 0
    error_message = "role_name must be a non-empty IAM role name."
  }
}

variable "state_bucket" {
  description = "S3 bucket name that stores Terraform/OpenTofu state."
  type        = string

  validation {
    condition     = length(trimspace(var.state_bucket)) > 0
    error_message = "state_bucket must be a non-empty S3 bucket name."
  }
}

variable "locks_table" {
  description = "DynamoDB table name used for Terraform/OpenTofu state locking."
  type        = string

  validation {
    condition     = length(trimspace(var.locks_table)) > 0
    error_message = "locks_table must be a non-empty DynamoDB table name."
  }
}

variable "aws_region" {
  description = "AWS region that hosts the DynamoDB lock table."
  type        = string

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must be a non-empty AWS region name."
  }
}

variable "tags" {
  description = "Tags to apply to created IAM policy resources."
  type        = map(string)
  default     = {}
}

variable "github_repository" {
  description = "Optional GitHub repository in owner/repo format; when set, writes TF_STATE_BUCKET and TF_STATE_TABLE GitHub Actions secrets."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.github_repository == null || can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be null or in owner/repo format."
  }
}
