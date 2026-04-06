# Challenge #1 — Terraform State Bootstrap (S3 + DynamoDB)

## Objective

Set up a secure, shared, and remote Terraform backend to store `terraform.tfstate` in AWS.

This challenge builds the foundation of a clean IaC workflow:

- state storage in **S3**,
- state locking with **DynamoDB**,
- team-ready collaboration with centralized state and locking.

## What was implemented

### 1) Terraform project initialization

- AWS provider configured with version constraints.
- AWS region externalized via variable (`aws_region`).

### 2) S3 bucket creation for state

- Dedicated Terraform state bucket (`aws_s3_bucket`).
- Versioning enabled (`aws_s3_bucket_versioning`).
- AES-256 server-side encryption enabled (`aws_s3_bucket_server_side_encryption_configuration`).
- Public access fully blocked (`aws_s3_bucket_public_access_block`).

### 3) DynamoDB lock table creation

- DynamoDB table created (`aws_dynamodb_table`).
- `PAY_PER_REQUEST` billing mode to keep it simple and Free Tier-friendly.
- Partition key: `LockID` (type `S`) for Terraform state locking.

### 4) Remote backend setup

- `backend.tf` prepared with an `s3` backend.
- Expected parameters: `bucket`, `key`, `region`, `dynamodb_table`, `encrypt = true`.

### 5) Bootstrap process

Recommended execution order:

1. `terraform init -backend=false`
2. `terraform apply` (create bucket + table)
3. add/configure `backend.tf`
4. `terraform init -reconfigure -migrate-state`

## Expected deliverables

- `terraform state list` runs without errors.
- State is stored in S3 (remote backend active).
- State locking is handled by DynamoDB.

## Notes

- The S3 bucket name must be **globally unique** and lowercase.
- Sensitive values (AWS credentials, private variables) must never be committed.
