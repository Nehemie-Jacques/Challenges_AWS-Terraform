variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr_block-app" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_block-tools" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}