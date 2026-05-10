# Challenge #10 — Inter-VPC Connectivity with VPC Peering

**Level:** Advanced | **Services:** VPC Peering, Route Tables, EC2, SSM, Security Groups

## 🎯 Objective

In enterprise architectures, environments (e.g., Application vs Management/Tools) are explicitly separated into different VPCs to limit blast radiuses and enforce strict security boundaries. However, they occasionally need to communicate securely using private IP addresses.

This challenge demonstrates how to establish a secure **VPC Peering Connection** between two VPCs, configure the crossed routing, and apply strict Security Group rules to allow `ping` (ICMP) traffic strictly from within the peer network.

---

## 🏗️ Architecture Deep Dive & Implementation

### 1. Dual VPC Setup with Non-Overlapping CIDRs
VPC Peering strictly prohibits routing if IP ranges overlap. We deployed:
- **VPC App:** `10.0.0.0/16`
- **VPC Tools:** `10.1.0.0/16`
Both VPCs have an Internet Gateway and public subnets solely to allow the SSM Agent to register with AWS for secure terminal access without SSH.

### 2. VPC Peering Connection
Created an `aws_vpc_peering_connection` acting as a private, high-speed tunnel traversing the AWS backbone network between the two VPCs. Since both VPCs are in the same account, we enabled `auto_accept = true` to simplify the handshake.

### 3. Crossed Route Tables (The most common pitfall)
Peering only creates the link; you must tell the VPCs to use it:
- A route in the **App Route Table** directs traffic destined for `10.1.0.0/16` to the Peering Connection.
- A route in the **Tools Route Table** directs traffic destined for `10.0.0.0/16` to the Peering Connection.

### 4. Zero-Trust Security Groups
Instead of allowing `0.0.0.0/0`, the Security Groups explicitly trust only the opposite VPC's CIDR:
- App SG allows ICMP strictly from `10.1.0.0/16`.
- Tools SG allows ICMP strictly from `10.0.0.0/16`.

---

## ✅ Validation test

```bash
# 1. Apply infrastructure
terraform apply -auto-approve

# 2. Get the Instance ID of the App server and Private IP of the Tools server
terraform output

# 3. Connect to the App Server via AWS Systems Manager
aws ssm start-session --target <app_instance_id>

# 4. Once inside the App server terminal, ping the specific Private IP of the Tools server
ping <tools_instance_private_ip>
```
If the ping returns packets successfully, the routing and peering connection are fully operational.

---

## Thought-provoking Question

### Is VPC Peering Transitive?      
**No, VPC Peering is NOT transitive.** If A is peered with B, and B is peered with C, A cannot communicate with C. A new, explicit peering connection would need to be created between A and C.
This is a major problem at scale. If a company has 100 VPCs that all need to communicate with each other, it would require creating *(100 * 99) / 2 = 4950* peering connections! This is what's known as the "Full Mesh" nightmare. To solve this, AWS offers **Transit Gateway**, which acts as a central hub (star routing): each VPC connects to the Transit Gateway, greatly simplifying network management.
