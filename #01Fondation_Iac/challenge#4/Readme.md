# Challenge #4 — Reusable Terraform Module Creation

## Objective

In enterprise environments, infrastructure code is rarely written from scratch for every project. Platform teams build and maintain an internal registry of validated modules that application teams consume. 

This challenge focuses on creating a **Custom Child Module** defining a strict interface, and consuming it via a **Root Module** to deploy multiple environments without duplicating code.

The goal is to deploy an S3 bucket configured for static website hosting, utilizing advanced Terraform logic like conditional resource creation.

## What was implemented

### 1) Child Module Design (`modules/terraform-aws-static-site`)
- **Variables interface (`variables.tf`):** Designed before writing resources. Included mandatory inputs (`bucket_name`) and optional ones with default values (`tags`, `bucket_policy`).
- **Resource configuration (`main.tf`):** 
  - Created the S3 bucket with versioning and public access block logic (learned in Challenge #1).
  - Configured website hosting settings (`aws_s3_bucket_website_configuration`) with `index.html` and `error.html`.
- **Conditional logic:** Utilized the `count` meta-argument (`count = var.bucket_policy != null ? 1 : 0`) to dynamically attach an IAM policy only if the user provides one.
- **Outputs defined (`outputs.tf`):** Exposed `ARN_bucket`, `bucket_name`, and the `url_web_site` so the root module can retrieve them.

### 2) Root Module Implementation
- Kept the `provider` block strictly out of the child module to ensure reusability across different AWS accounts or regions.
- Called the module twice in the `main.tf` file:
  - One instance for a **development** environment with specific tags and bucket name.
  - One instance for a **production** environment.
- Mapped the module outputs to root outputs to display the final website URLs in the console.

## Expected Deliverables

- `terraform plan` successfully shows the creation of resources for both `dev` and `prod` simultaneously.
- No `provider` limits inside the child module.
- Outputs successfully display the S3 website endpoint URLs.

## Useful Commands

```bash
# Initialize the project (downloads the local module into .terraform/)
terraform init

# Validate the syntax and configuration
terraform validate

# Preview the changes
terraform plan

# Apply the module configuration
terraform apply -auto-approve
```