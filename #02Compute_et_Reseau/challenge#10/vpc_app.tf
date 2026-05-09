resource "aws_vpc" "vpc_app" {
  cidr_block = var.vpc_cidr_block-app
  tags = {
    Name = "VPC-App"
  }
}