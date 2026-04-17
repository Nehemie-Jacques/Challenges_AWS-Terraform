variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "challenge2"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "The number of availability zones"
  type        = number
  default     = 2
}

variable "subnet_newbits" {
  description = "Additional prefix bits to create subnets from VPC CIDR"
  type        = number
  default     = 8
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "ec2_ssm_role" {
  description = "The name of the IAM role for EC2 SSM"
  type = string
  default = "ec2_ssm_role"
}

variable "ec2_ssm_profile" {
  description = "The name of the IAM instance profile for EC2 SSM"
  type = string
  default = "ec2_ssm_profile"
}