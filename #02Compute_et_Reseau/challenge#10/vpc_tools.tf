resource "aws_vpc" "vpc_tools" {
  cidr_block = var.vpc_cidr_block-tools
  tags = {
    Name = "VPC-Tools"
  }
}