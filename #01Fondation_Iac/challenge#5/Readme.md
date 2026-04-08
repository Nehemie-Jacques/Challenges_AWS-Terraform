# Challenge #5 — Importing Existing Resources into Terraform State

## Objective

In real-world enterprise environments, DevOps engineers often inherit manually created infrastructure (ClickOps). Destroying and recreating these resources in production is not an option.

This challenge focuses on taking control of existing, unmanaged AWS resources (an EC2 instance and an S3 bucket) by mapping them to Terraform code and importing them into the `terraform.tfstate` without causing downtime or physical modifications.

## What was implemented

### 1) Initial Setup & Manual Creation
- Acted as a legacy user by manually creating an AWS `t3.micro` EC2 instance and an S3 bucket via the AWS Management Console.

### 2) Resource Configuration (`main.tf`)
- Wrote minimal `aws_instance` and `aws_s3_bucket` blocks matching the manually created resources.
- Intentionally left out auto-generated AWS configurations to observe the drift during the planning phase.

### 3) Import Process
- Used the `terraform import` CLI command to link the real-world AWS IDs to the local Terraform resource blocks.
- **Note:** The state file was updated, but the physical AWS resources remained completely untouched.

### 4) Configuration Drift Resolution
- Analyzed the output of `terraform plan` to identify discrepancies between the Terraform code and the actual AWS state.
- Implemented the `lifecycle` block (`ignore_changes = [...]`) inside the `aws_instance` and `aws_s3_bucket` resources to explicitly ignore AWS-generated default settings (e.g., default security groups, metadata options).

## Expected Deliverables

- `terraform state list` successfully displays the newly imported EC2 instance and S3 bucket.
- Running `terraform plan` reports: **"No changes. Your infrastructure matches the configuration."**
- A properly configured `lifecycle` block documenting ignored attributes.

## Useful Commands

```bash
# Import the existing S3 bucket
terraform import aws_s3_bucket.state <your-bucket-name>

# Import the existing EC2 instance
terraform import aws_instance.import <i-0abcd1234efgh5678>

# Verify state tracking
terraform state list

# Check for configuration drift (Aiming for "No changes")
terraform plan
```