# Terraform Backend Access Module

Creates an IAM managed policy that grants Terraform/OpenTofu backend access to an S3 state bucket and DynamoDB lock table, attaches it to a target IAM role, and can optionally manage related GitHub Actions secrets.

## Usage

```hcl
module "terraform_backend_access" {
  source = "github.com/omsf/lambdacron//modules/github-s3-tfstate-access"

  role_name    = aws_iam_role.deployer.name
  state_bucket = "my-tf-state"
  locks_table  = "my-tf-state-locks"
  aws_region   = "us-east-2"
}
```

Optional GitHub Actions secrets management:

```hcl
module "terraform_backend_access" {
  source = "github.com/omsf/lambdacron//modules/github-s3-tfstate-access"

  role_name         = aws_iam_role.deployer.name
  state_bucket      = "my-tf-state"
  locks_table       = "my-tf-state-locks"
  aws_region        = "us-east-2"
  github_repository = "my-org/my-repo"
}
```

## Inputs

- `role_name` (string): IAM role name to attach backend access policy to.
- `state_bucket` (string): S3 bucket name storing Terraform/OpenTofu state.
- `locks_table` (string): DynamoDB table name storing Terraform/OpenTofu locks.
- `aws_region` (string): Region for the lock table.
- `tags` (map(string)): Optional resource tags.
- `github_repository` (string, optional): `owner/repo`; when set, manages `TF_STATE_BUCKET` and `TF_STATE_TABLE` GitHub Actions secrets.

## Outputs

- `policy_arn`: Managed policy ARN.
- `policy_name`: Managed policy name.
- `policy_json`: Rendered policy document JSON.
- `attached_role_name`: Role name the policy is attached to.
- `github_actions_secret_names`: Names of managed GitHub Actions secrets.
- `github_actions_repository_name`: Repository name receiving managed secrets, or `null`.
