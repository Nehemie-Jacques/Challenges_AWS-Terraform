# Challenge #6 — 3-Tier Architecture: ALB + Auto Scaling Group + RDS

**Level:** Intermediate | **Services:** EC2, ALB, ASG, RDS, VPC, Security Groups

## 🎯 Objective

The **3-Tier Architecture** is the most widely adopted pattern for enterprise web applications. It separates the infrastructure into three distinct layers:
1. **Presentation Tier:** A Load Balancer exposed to the internet.
2. **Application Tier:** Web/App servers processing the logic.
3. **Data Tier:** A database storing the persistent data.

The goal of this challenge is to fully automate the deployment of this architecture using Terraform, while adhering strictly to production-grade security standards, high availability, and the Principle of Least Privilege.

---

## 🏗️ Architecture Deep Dive & Implementation

Here is a detailed breakdown of exactly how this infrastructure was built and why.

### 1. Network Isolation (VPC & Subnets)
To ensure maximum security, the infrastructure is deployed across a custom Virtual Private Cloud (VPC) spanning 2 Availability Zones (for High Availability).
- **Public Subnets:** Contain the Application Load Balancer (ALB). They have a direct route to the Internet Gateway (IGW).
- **Private Subnets:** Contain the EC2 instances and the RDS database. They **do not** have a route to the internet. This prevents any direct external attack on the servers or the database.

### 2. Security Group Chaining (The Principle of Least Privilege)
Instead of allowing IP ranges (CIDRs), we used Terraform to chain Security Groups by referencing their IDs. This is a critical security pattern:
- **`sg_alb` (Load Balancer SG):** The only entry point. Allows HTTP (Port 80) traffic from anywhere (`0.0.0.0/0`).
- **`sg_ec2` (Application SG):** Blocks all internet traffic. It only allows HTTP (Port 80) traffic coming **specifically from the `sg_alb`**.
- **`sg_rds` (Database SG):** Blocks all internet and random VPC traffic. It only allows MySQL (Port 3306) traffic coming **specifically from the `sg_ec2`**.

### 3. The Presentation Tier (ALB & Target Groups)
- Created an **Application Load Balancer (`aws_lb`)** placed in the public subnets.
- Configured a **Target Group (`aws_lb_target_group`)**. The ALB doesn't route traffic directly to instances; it routes to the Target Group. 
- The Target Group continuously performs **Health Checks** on the `/` path to ensure traffic is only sent to healthy EC2 instances.

### 4. The Application Tier (Launch Template & ASG)
- **Launch Template (`aws_launch_template`):** Serves as the blueprint for the virtual machines. It defines the AMI, instance type (`t3.micro`), and assigns the `sg_ec2`.
- **Dynamic Configuration (`user_data`):** A bash script runs automatically on boot. It installs an Apache web server and dynamically injects the RDS database endpoint into the HTML file using Terraform interpolation (`${aws_db_instance.main.endpoint}`).
- **Auto Scaling Group (`aws_autoscaling_group`):** Placed in the private subnets. It ensures there are always 2 instances running. It automatically registers new instances into the ALB's Target Group.

### 5. The Data Tier (Amazon RDS)
- Created a **DB Subnet Group (`aws_db_subnet_group`)** to tell RDS which private subnets it is allowed to use.
- Deployed a **MySQL RDS Instance (`aws_db_instance`)** (`db.t3.micro`). The administrator password is not hardcoded; it is passed securely via a `sensitive = true` Terraform variable.

---

## 💡 Key Learnings

- **Why put EC2s in private subnets if the ALB needs to talk to them?** "Private" just means they don't have public IP addresses and can't be reached from the outside internet. The ALB, being in the same VPC, can easily communicate with them via their private IP addresses.
- **Why use a Target Group?** In an Auto Scaling environment, EC2 instances are constantly created and destroyed. The ALB cannot rely on static IPs. The ASG dynamically registers and deregisters instances from the Target Group, acting as a dynamic phonebook for the Load Balancer.

---

## ✅ Expected Deliverables

1. Running `terraform output alb_dns_name` provides a URL. Pasting this URL in a browser displays the "Hello World" page along with the dynamically injected RDS endpoint.
2. Direct access to the EC2 or RDS instances via IP is impossible from the outside.
3. The database password never appears in plaintext in the console outputs due to the `sensitive` flag.

---

## 🚀 Usage Commands

```bash
# 1. Initialize the Terraform working directory
terraform init

# 2. Review the execution plan (You will be prompted for the DB password)
terraform plan -var="db_password=YourSecurePassword123!"

# 3. Apply the infrastructure
terraform apply -var="db_password=YourSecurePassword123!" -auto-approve

# 4. View the outputs to get the Load Balancer DNS
terraform output

# 5. Clean up the infrastructure to avoid AWS charges
terraform destroy -var="db_password=YourSecurePassword123!" -auto-approve
```