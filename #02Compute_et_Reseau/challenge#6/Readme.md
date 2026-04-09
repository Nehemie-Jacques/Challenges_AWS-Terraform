# Challenge #6 — 3-Tier Architecture: ALB + Auto Scaling Group + RDS

## Objective

Build a classic enterprise 3-tier web architecture on AWS using Infrastructure as Code. The architecture consists of a Presentation tier (Application Load Balancer), an Application tier (EC2 instances managed by an Auto Scaling Group), and a Data tier (RDS MySQL).

This challenge emphasizes network isolation, high availability, and the Principle of Least Privilege using chained Security Groups.

## What was implemented

### 1. Network Foundation
- Created a VPC with 2 Public Subnets and 2 Private Subnets across 2 Availability Zones.
- Setup an Internet Gateway and Route Tables to route public subnet traffic to the internet while keeping private subnets isolated.

### 2. Security Group Chaining (Least Privilege)
Strict network boundaries were applied:
- **ALB Security Group:** Allows inbound HTTP (80) traffic from anywhere (`0.0.0.0/0`).
- **EC2 Security Group:** Allows inbound HTTP (80) traffic **only** from the ALB Security Group. Instances cannot be accessed directly from the internet.
- **RDS Security Group:** Allows inbound MySQL (3306) traffic **only** from the EC2 Security Group.

### 3. Application Tier (ASG & EC2)
- Created an `aws_launch_template` defining the EC2 setup (AMI, type, private networking).
- Injected an interpolated `user_data` script (Base64 encoded) that starts an Apache web server and writes the dynamic RDS endpoint into the `index.html`.
- Attached an `aws_autoscaling_group` placed in the **Private Subnets**, linked directly to the ALB Target Group for automated health checks and traffic distribution.

### 4. Presentation & Data Tiers
- **ALB:** Deployed an `aws_lb` in the Public Subnets, with a Listener (`aws_lb_listener`) and Target Group (`aws_lb_target_group`).
- **RDS:** Deployed an `aws_db_instance` (MySQL db.t3.micro) in a private `aws_db_subnet_group`. Uses a `sensitive = true` variable for the database password.

## Expected Deliverables

- Output `alb_dns_name` is provided to access the application via a web browser.
- Output `rds_endpoint` shows the database connection string.
- Instances are successfully scaled automatically based on the ASG configurations and are healthy inside the ALB Target Group.

## Usage

```bash
# Don't forget to pass the sensitive DB password when planning/applying
terraform init
terraform plan -var="db_password=YourSecurePassword123!"
terraform apply -var="db_password=YourSecurePassword123!" -auto-approve
```