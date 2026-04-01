resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  
  tags = var.tags

  enable_dns_hostnames = true
  enable_dns_support = true
}

data "aws_availability_zones" "available" {
  state = "available"
}