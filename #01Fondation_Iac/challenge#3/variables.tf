variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "The environment for which to create resources"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of : dev, staging, prod"
  }
}

variable "name_prefix" {
  description = "The prefix for the resource names"
  type        = string

  validation {
    condition = (
      length(var.name_prefix) >= 3 &&
      length(var.name_prefix) <= 30 &&
      can(regex("^[a-z0-9-]+$", var.name_prefix))
    )
    error_message = "name_prefix must be 3-30 chars and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "bucket_name_override" {
  description = "The override for the S3 bucket name"
  type        = string
  default     = null

  validation {
    condition = var.bucket_name_override == null || (
      length(var.bucket_name_override) >= 3 &&
      length(var.bucket_name_override) <= 63 &&
      can(regex("^[a-z0-9.-]+$", var.bucket_name_override))
    )
    error_message = "bucket_name_override must be 3-63 chars and contain only lowercase letters, numbers, dots, or hyphens."
  }
}

variable "tags" {
  description = "Default tags for resources"
  type        = map(string)
  default     = {}
}

variable "db_password" {
  description = "Dummy sensitive variable for practice"
  type        = string
  sensitive   = true
}