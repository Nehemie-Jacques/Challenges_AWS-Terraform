variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default = "my-tf-test-bucket"

  validation {
    condition = length(aws_s3_bucket.bucket) > 0 && length(aws_s3_bucket.bucket) <= 63
    error_message = "Bucket name must be between 3 and 63 characters long"
  }
}

variable "prod_tags" {
  description = "Tags for production resources"
  type        = map(string)
  default = {
    Name        = "My bucket"
    Environment = "Prod"
  }
}

variable "staging_tags" {
  description = "Tags for staging resources"
  type        = map(string)
  default = {
    Name        = "My bucket"
    Environment = "Staging"
  }
}

variable "dev_tags" {
  description = "Tags for development resources"
  type        = map(string)
  default = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}