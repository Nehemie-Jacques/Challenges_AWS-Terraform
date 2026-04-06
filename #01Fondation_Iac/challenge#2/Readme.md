# Challenge #2 — Full VPC with Public and Private Subnets

## Objective

Build an isolated and reusable AWS network foundation for upcoming challenges:

- 1 custom VPC (not the default VPC),
- 2 public subnets across 2 AZs,
- 2 private subnets across the same 2 AZs,
- 1 Internet Gateway,
- 1 public route table + 1 private route table,
- route table associations to the correct subnets.

## What was implemented

### 1) Provider and backend

- AWS provider configured in `provider.tf` with:
  - `required_version = ">= 1.6.0"`
  - `hashicorp/aws` provider pinned to `~> 5.0`
  - region externalized through `var.aws_region`.
- S3 backend configured in `backend.tf` with DynamoDB locking (`terraform-locks`).

### 2) Variables and parametrization

In `variables.tf`, the following values are parameterized:

- `aws_region`
- `project`
- `environment`
- `vpc_cidr_block`
- `az_count`
- `subnet_newbits`

This setup makes the challenge easy to adapt to other environments.

### 3) Network creation (in `main.tf`)

- AZs retrieved dynamically through `data "aws_availability_zones" "available"`.
- AZ selection handled with `slice(...)` based on `az_count`.
- Subnet CIDRs computed with `cidrsubnet()` (no hardcoding).
- VPC created with DNS enabled (`enable_dns_hostnames` and `enable_dns_support`).
- Public subnets created with `map_public_ip_on_launch = true`.
- Private subnets created with `map_public_ip_on_launch = false`.
- Internet Gateway attached to the VPC.
- Public route table with `0.0.0.0/0` route to IGW.
- Private route table with no direct Internet route.
- Route table ↔ subnet associations completed.

## Deliverables status

### ✅ Implemented

- Custom VPC + 4 subnets (2 public / 2 private) generated dynamically.
- Public routing through IGW and isolated private routing.

### 🟡 To finalize

- Ensure output values are populated in state (run `terraform apply` if infrastructure is not yet created in this state).
- Keep backend key format clean and stable (`challenge-02/terraform.tfstate`).

## Why does the private route table have no IGW route?

A private subnet must not be directly exposed to the Internet.
If private instances need outbound Internet access for updates, add a **NAT Gateway** (in a public subnet) and then a `0.0.0.0/0` route from the private route table to the NAT.

## Useful commands

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
```
