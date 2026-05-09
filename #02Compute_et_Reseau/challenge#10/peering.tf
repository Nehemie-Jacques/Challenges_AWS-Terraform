resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.vpc_app.id
  peer_vpc_id   = aws_vpc.vpc_tools.id 
  auto_accept   = true
  tags = { Name = "App-to-Tools-Peering" }
}

# Route dans le VPC App pour atteindre le VPC Tools
resource "aws_route" "app_to_tools" {
  route_table_id            = aws_route_table.app.id
  destination_cidr_block    = aws_vpc.vpc_tools.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Route dans le VPC Tools pour atteindre le VPC App
resource "aws_route" "tools_to_app" {
  route_table_id            = aws_route_table.tools.id
  destination_cidr_block    = aws_vpc.vpc_app.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}