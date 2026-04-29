# Challenge #8 — Highly Available NAT Gateway (Multi-AZ)

**Level:** Intermediate | **Services:** VPC, NAT Gateway, Route Tables, Elastic IPs (EIP)

## 🎯 Objective

A single NAT Gateway creates a **Single Point of Failure (SPOF)**. If the Availability Zone housing the NAT goes down, all instances across all AZs lose their outbound internet access. The AWS Well-Architected Framework mandates that each AZ possesses its own NAT Gateway for High Availability (HA) in production.

The goal of this challenge is to build a dynamically scalable network that alternates between Cost-Saving Mode (1 shared NAT) and Production HA Mode (1 NAT per AZ) simply by toggling a single Terraform variable `enable_nat_ha`.

---

## 🏗️ Architecture Deep Dive & Implementation

Here is the exact mechanism built using Terraform meta-arguments and functions:

### 1. Cost versus Availability Toggle (`enable_nat_ha`)
We introduced a boolean variable `enable_nat_ha`. 
- When `false`: Terraform deploys 1 NAT Gateway, 1 Elastic IP, and 1 Private Route Table. All private subnets share this single NAT.
- When `true`: Terraform dynamically calculates the number of AZs being used (`var.az_count`) and provisions `N` NAT Gateways, `N` Elastic IPs, and `N` Private Route Tables.

### 2. Dynamic Count Evaluation (`count`)
Applied the ternary operator `count = var.enable_nat_ha ? var.az_count : 1` directly on the `aws_eip`, `aws_nat_gateway`, and `aws_route_table` resources.

### 3. Smart Subnet Mapping (`index()` function)
The hardest part of this challenge was ensuring that Private Subnet A points *only* to NAT Gateway A, and Private Subnet B points *only* to NAT Gateway B when HA is enabled. 
Using `index(local.selected_azs, each.key)`, Terraform successfully isolates the routing. If one AZ goes down, the routing table prevents cross-AZ failure.

### 4. Internet Gateway Dependency
Explicitly added a `depends_on = [aws_internet_gateway.gw]` in the NAT Gateway resource. AWS requires the IGW to be fully provisioning and attached to the VPC before a NAT Gateway can obtain internet access.

---

## ✅ Expected Deliverables

1. Modifying `enable_nat_ha = false` results in a Terraform plan creating exactly 1 NAT Gateway.
2. Modifying `enable_nat_ha = true` results in a Terraform plan extending to `N` NAT Gateways (matching `var.az_count`).
3. Each Private Subnet is correctly routed to the proper AZ-bound Private Route Table in HA mode.

---

## 🚀 Usage Commands

```bash
# 1. Preview in Dev mode (Cost Saving)
terraform plan -var="enable_nat_ha=false"

# 2. Preview in Prod mode (High Availability)
terraform plan -var="enable_nat_ha=true"

# 3. Apply the HA mode
terraform apply -var="enable_nat_ha=true" -auto-approve

# 4. Clean up AWS Charges (NAT Gateways are expensive!)
terraform destroy -auto-approve
```
---

## Question de réflexion

### 1. Pourquoi place-t-on le NAT Gateway dans un subnet public ?
Un NAT (Network Address Translation) fait le pont entre un réseau privé et l'Internet. S'il était placé dans un sous-réseau privé, il n'aurait pas de route vers l'Internet Gateway (IGW) pour sortir. L'instance NAT doit avoir une IP publique (EIP) et une route directe vers la sortie.

### 2. Quel est l'impact financier de enable_nat_ha
En production, la NAT Gateway est souvent l'un des postes de dépenses les plus élevés dans la section réseau, principalement parce qu'elle est facturée 24h/24.