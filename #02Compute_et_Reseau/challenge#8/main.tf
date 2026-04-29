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
    for i, az in local.selected_azs :
    az => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, i)
  }

  private_subnets = {
    for i, az in local.selected_azs :
    az => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, i + var.az_count)
  }
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    name = "${var.project}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    name = "${var.project}-${var.environment}-public-subnet-${each.key}"
    Tier = "Public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    name = "${var.project}-${var.environment}-private-subnet-${each.key}"
    Tier = "Private"
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" {
  domain = "vpc"
  count  = var.enable_nat_ha ? var.az_count : 1

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-eip-${count.index + 1}"
  })
}


resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_ha ? var.az_count : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[local.selected_azs[count.index]].id
  depends_on    = [aws_internet_gateway.gw]

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat-${count.index + 1}"
  })
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_ha ? var.az_count : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = var.enable_nat_ha ? aws_route_table.private[index(local.selected_azs, each.key)].id : aws_route_table.private[0].id
}
