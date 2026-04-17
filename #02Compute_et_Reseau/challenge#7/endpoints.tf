locals {
  services = ["ssm", "ssmmessages", "ec2messages"]
}

resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = toset(local.services)

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_sg.id]
  subnet_ids          = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true
}