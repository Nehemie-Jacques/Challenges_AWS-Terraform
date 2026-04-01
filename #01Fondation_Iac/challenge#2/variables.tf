variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-3"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags for the VPC"
  type        = map(string)
  default     = {
    Name = "main"
    project = "challenge2"
    environment = "dev"
  }
}