# Challenge #7 — Secure Bastion Host with SSM Session Manager (No SSH)

**Level:** Intermediate | **Services:** EC2, IAM, SSM, VPC Endpoints, Security Groups

## 🎯 Objective

Opening port `22` (SSH) to the internet is a major security vulnerability and a deprecated practice in modern Cloud Architecture. The AWS Well-Architected Framework recommends using **AWS Systems Manager (SSM) Session Manager** to access instances securely.

The goal of this challenge is to build a completely isolated "Bastion Host" (an EC2 instance in a private subnet with NO internet access) and connect to its terminal securely using the AWS API via VPC Endpoints, totally bypassing the need for SSH keys.

---

## 🏗️ Architecture Deep Dive & Implementation

Here is how the infrastructure is constructed to provide a mathematically secure connection:

### 1. Completely Private Networking
- Created a **VPC** with **Private Subnets only**.
- There is **No Internet Gateway (IGW)** and **No NAT Gateway**. The EC2 instance has absolutely zero path to the public internet.

### 2. IAM Role & Instance Profile
For the SSM Agent (pre-installed on Amazon Linux 2) to communicate with the AWS API, the instance needs cryptographic permissions:
- Created an `aws_iam_role` allowing the `ec2.amazonaws.com` service to assume it.
- Attached the AWS Managed Policy `AmazonSSMManagedInstanceCore` to grant the exact privileges required for Session Manager.
- Wrapped the role in an `aws_iam_instance_profile` and attached it to the EC2.

### 3. Absolute Zero-Ingress Security Groups
Unlike a traditional bastion that requires `Ingress: Port 22 from 0.0.0.0/0`, this setup requires **Zero Ingress Rules** on the instance.
- **EC2 Security Group:** Only allows `Egress: Port 443` (Outbound HTTPS). The SSM connection is initiated by the instance polling the SSM API, not the other way around.

### 4. VPC Endpoints (AWS PrivateLink)
Since the instance has no internet access, it cannot reach the public AWS SSM API. We created **VPC Endpoints** (`Interface` type), which inject the AWS API directly into our private subnets via private IP addresses:
- `com.amazonaws.[region].ssm`
- `com.amazonaws.[region].ssmmessages` (Crucial for the Session Manager shell)
- `com.amazonaws.[region].ec2messages`
- **Endpoint Security Group:** Allows `Ingress: Port 443` originating specifically from the VPC CIDR block.

---

## ✅ Expected Deliverables

1. The EC2 instance is successfully provisioned entirely in a private network without a public IP.
2. The Security Group attached to the EC2 has zero inbound rules.
3. You can access the EC2 instance's shell via the AWS CLI.

---

## 🚀 Usage Commands

```bash
# 1. Initialize and apply the Terraform configuration
terraform init
terraform apply -auto-approve

# 2. Get the Instance ID from the outputs
# Doit renvoyer quelque chose comme: i-0abcd123456789

# 3. Start a secure terminal session using the AWS CLI
aws ssm start-session --target $(terraform output -raw instance_id)

# 4. Once inside the shell, you are root/ssm-user securely without SSH!
# Type 'exit' to close the session.

# 5. Clean up
terraform destroy -auto-approve
```