resource "aws_vpc" "vpc_tools" {
  cidr_block = var.vpc_cidr_block-tools
  tags = {
    Name = "VPC-Tools"
  }
}

resource "aws_subnet" "subnet_tools" {
  vpc_id                  = aws_vpc.vpc_tools.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet-Tools"
  }
}

resource "aws_security_group" "allow_icmp_cross_vpc" {
  name        = "allow_icmp_from_other_vpc"
  description = "Autorise le trafic ICMP entrant depuis le VPC distant"
  vpc_id      = aws_vpc.vpc_tools.id

  ingress = {
    description = "Trafic ICMP entrant depuis le VPC distant"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc_app.cidr_block]
  }

  egress = {
    description = "Autorisation de tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_icmp_cross_vpc"
  }
}

resource "aws_instance" "tools_instance" {
  ami                    = "ami-0c7191dc6b3e08b56"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_tools.id
  vpc_security_group_ids = [aws_security_group.allow_icmp_cross_vpc.id]
}