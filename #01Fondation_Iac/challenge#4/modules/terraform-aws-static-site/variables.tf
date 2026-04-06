variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
  default     = "bucket"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {}
}

variable "bucket_policy" {
  description = "Optional IAM policy JSON to attach to the bucket"
  type    = string
  default = null
}