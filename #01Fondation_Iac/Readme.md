# Section #01 — Terraform Foundations (IaC)

## Overview

This section covers the absolute foundational concepts of Infrastructure as Code (IaC) using Terraform on AWS. These challenges reflect real-world tasks expected of a Junior to Mid-level DevOps / Cloud Engineer. The primary goal is to establish secure, scalable, and reusable infrastructure patterns from day one.

## Challenges Summary

### [Challenge #1: Terraform State Bootstrap (S3 + DynamoDB)](./challenge%231/readme.md)
**Focus:** Remote state management and locking.
Built the foundational backend for all future projects by deploying an encrypted S3 bucket for state storage and a DynamoDB table (`PAY_PER_REQUEST`) for state locking to prevent concurrent modifications.

### [Challenge #2: Full VPC with Public and Private Subnets](./challenge%232/readme.md)
**Focus:** AWS Networking infrastructure.
Provisioned a custom, production-grade VPC dynamically spanning multiple Availability Zones. Included Public/Private subnet isolation, Internet Gateway, and highly customized Route Tables avoiding hardcoded CIDR blocks.

### [Challenge #3: Variables and Environments (Dev/Staging/Prod)](./challenge%233/readme.md)
**Focus:** DRY principles and Multi-environment deployments.
Separated code from configuration by utilizing `variables.tf` and `.tfvars` files. Implemented strict variable validation, handled sensitive data masking, and successfully reused identical code to plan distinct Dev, Staging, and Prod environments.

### [Challenge #4: Reusable Terraform Module Creation](./challenge%234/readme.md)
**Focus:** Platform engineering and Modularity.
Shifted from writing flat configurations to authoring a reusable Child Module for statically hosted S3 websites. Demonstrated the ability to expose inputs/outputs, use conditional resource creation (`count`), and safely consume the module from a Root Module across multiple environments.

### [Challenge #5: Importing Existing Resources into State](./challenge%235/readme.md)
**Focus:** Infrastructure Management and Drift Resolution.
Simulated the inheritance of unmanaged infrastructure (ClickOps). Successfully mapped manually created AWS EC2 and S3 resources into Terraform code, imported them using the CLI, and neutralized configuration drift using `lifecycle { ignore_changes }` to align the code directly with reality.