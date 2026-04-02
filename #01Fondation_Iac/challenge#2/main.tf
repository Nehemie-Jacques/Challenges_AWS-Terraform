data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  public_subnets = {
    for i, az in locals.selected_azs :
    az => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, i)
  }

  private_subnets = {
    for i, az in locals.selected_azs :
    az => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, i + var.az_count)
  }
}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(local.common_tags, {
    name = "${var.project}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    name = "${var.project}-${var.environment}-public-subnet-${each.key}"
    Tier = "Public"
  })
}
