variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
  default     = "bucket"
}

variable "lock_table_name" {
  description = "The name of the DynamoDB table to use for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "Terraform Bootstrap state Terraform"
  }
}