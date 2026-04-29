variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "aws_region_east" {
  description = "The AWS region for ACM certificates"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
  default     = "bucket"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "bucket_policy" {
  description = "Optional IAM policy JSON to attach to the bucket"
  type        = string
  default     = null
}

variable "oac_for_s3_bucket" {
  description = "The name of the CloudFront origin access control"
  type        = string
  default     = "Cloudfront_OCA"
}