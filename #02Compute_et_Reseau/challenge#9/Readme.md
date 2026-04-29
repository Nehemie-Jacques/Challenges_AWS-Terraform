# Challenge #09 — CloudFront CDN with S3 Static Website & OAC

**Level:** Intermediate | **Services:** CloudFront, S3, ACM, IAM

## 🎯 Objective

Deploying a public S3 bucket for website hosting is risky. The production standard is to keep the S3 bucket **completely private** and serve the content through a **Content Delivery Network (CDN)** like CloudFront. 

This challenge focuses on implementing **Origin Access Control (OAC)** to ensure that S3 content is only accessible via CloudFront, providing global performance via caching and mandatory HTTPS.

---

## 🏗️ Architecture Deep Dive

### 1. Multi-Provider Setup
CloudFront is a global service, but it requires SSL certificates (ACM) to be provisioned in the `us-east-1` (N. Virginia) region. We implemented a **Provider Alias** to manage resources in our main region while creating the necessary global hooks in `us-east-1`.

### 2. Private S3 (Origin)
Unlike traditional static hosting, we disabled all public access on the S3 bucket:
- `block_public_policy = true`
- `restrict_public_buckets = true`
An `index.html` was uploaded as an `aws_s3_object` to serve as our landing page.

### 3. Origin Access Control (OAC)
We used the modern **aws_cloudfront_origin_access_control** resource. This allows CloudFront to cryptographically sign requests to S3. This is the successor to the deprecated OAI, providing better security and support for all AWS regions.

### 4. Locked-Down Bucket Policy
The S3 bucket was configured with a policy that allows `s3:GetObject` **only if** the request originates from our specific CloudFront Distribution ARN. This creates a "security perimeter" around our data.

### 5. CloudFront Distribution (CDN)
The distribution was configured to:
- Redirect all HTTP traffic to **HTTPS**.
- Use the S3 bucket's **Regional Domain Name** as the origin.
- Serve the `index.html` by default.
- Utilize the global Edge Location network to minimize latency for users.

---

## ✅ Expected Deliverables

1. The S3 bucket URL returns a **403 Forbidden** (Perfect security).
2. The CloudFront URL (output) displays the website over **HTTPS**.
3. All infrastructure is managed via code with no manual console intervention.

---

## 🚀 Usage Commands

```bash
# Initialize and apply
terraform init
terraform apply -auto-approve

# Test the access
curl -I $(terraform output -raw cloudfront_url)
```

---

## Thought-provoking Question

### 1.Difference between OAI and OAC:
OAI (Origin Access Identity) is the older method. It is limited because it does not support some newer AWS regions, does not support SSE-KMS encryption, and is not compatible with protocols other than S3.
OAC (Origin Access Control) is the recommended method because it supports all regions, enables Signature Version 4 (SigV4) authentication, and improves overall security.

### 2.Why us-east-1 for ACM?
CloudFront is a global service. However, its control plane for SSL/TLS certificates is centralized in the **us-east-1** region. For CloudFront to "see" and distribute your certificate across its hundreds of edge locations worldwide, the certificate must be stored in this central repository.