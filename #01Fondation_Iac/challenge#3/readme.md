# Challenge #3 — Variables and Environments (dev/staging/prod)

## Objective

Use one Terraform codebase to deploy multiple environments (`dev`, `staging`, `prod`) without duplicating code.

This challenge focuses on:

- strong variable design,
- input validation,
- sensitive data handling,
- per-environment configuration through `.tfvars` files.

## What was implemented

### 1) Fully parameterized resources (`main.tf`)

Two resources are created without hardcoded business values:

- `aws_s3_bucket.state`
- `aws_dynamodb_table.lock`

Resource names are dynamically built from variables:

- bucket: `${name_prefix}-${environment}-${account_id}` (or `bucket_name_override`),
- table: `${name_prefix}-${environment}-locks`.

### 2) Variable declarations (`variables.tf`)

Defined variables:

- `aws_region` (string)
- `environment` (string)
- `name_prefix` (string)
- `bucket_name_override` (string, optional)
- `tags` (map(string))
- `db_password` (string, `sensitive = true`)

### 3) Validation rules

Added validation on critical inputs:

- `environment` must be one of: `dev`, `staging`, `prod`.
- `name_prefix` must be 3–30 chars, lowercase, digits, hyphens only.
- `bucket_name_override` (if set) must respect S3 naming constraints.

### 4) Sensitive variable practice

`db_password` is marked as sensitive. Terraform masks it in plan/apply output.

### 5) Environment-specific `.tfvars`

Created three separate variable files:

- `dev.tfvars`
- `staging.tfvars`
- `prod.tfvars`

Each file has different environment values and tags.

### 6) Example file for Git

`terraform.tfvars.example` documents all expected inputs with dummy values.

## Outputs

Defined in `output.tf`:

- `s3_bucket_name`
- `dynamodb_table_name`
- `environment`

## Validation commands

```bash
terraform init
terraform fmt -recursive
terraform validate

terraform plan -var-file="dev.tfvars"
terraform plan -var-file="staging.tfvars"
terraform plan -var-file="prod.tfvars"
```

## Important concepts

### Variable declaration vs variable value

- In `variables.tf`, you define the contract: name, type, description, validation.
- In `.tfvars`, you provide concrete values for a given environment.

### Why `terraform.tfvars` is auto-loaded

Terraform automatically loads `terraform.tfvars` (and `*.auto.tfvars`) by convention.
Files like `dev.tfvars` are loaded only when explicitly passed with `-var-file`.
