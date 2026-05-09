resource "aws_vpc" "vpc_app" {
  cidr_block           = var.vpc_cidr_block-app
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-App" }
}

resource "aws_subnet" "subnet_app" {
  vpc_id                  = aws_vpc.vpc_app.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_app.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  tags                    = { Name = "Subnet-App" }
}

resource "aws_internet_gateway" "igw_app" {
  vpc_id = aws_vpc.vpc_app.id
  tags   = { name = "IGW-App" }
}

resource "aws_route_table" "rt_app" {
  vpc_id = aws_vpc.vpc_app.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_app.id
  }
  tags = { Name = "RT-App" }
}

resource "aws_route_table_association" "rta_app" {
  subnet_id      = aws_subnet.subnet_app.id
  route_table_id = aws_route_table.rt_app.id
}

resource "aws_security_group" "allow_icmp_cross_vpc" {
  name        = "allow_icmp_from_other_vpc"
  description = "Autorise le trafic ICMP entrant depuis le VPC tools"
  vpc_id      = aws_vpc.vpc_app.id

  ingress {
    description = "Trafic ICMP entrant depuis le VPC tools"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc_tools.cidr_block]
  }

  egress {
    description = "Autorisation de tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "allow_icmp_cross_vpc" }
}

resource "aws_instance" "app_instance" {
  ami                    = "data.aws_ami.amazon_linux_2.id"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_app.id
  vpc_security_group_ids = [aws_security_group.allow_icmp_cross_vpc.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  tags                   = { Name = "App-Instance" }
}