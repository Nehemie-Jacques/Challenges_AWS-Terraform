# 1. La demande (Compte Requester)
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.main.id
  peer_vpc_id   = "" # ID du VPC dans l'autre compte
  peer_owner_id = "" # ID du compte AWS distant
  auto_accept   = false
}

# 2. L'acceptation (Compte Accepter)
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.accepter # Provider lié au compte B
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

resource "aws_route" "app_to_tools" {
  route_table_id = aws_route_table.app.id
  destination_cidr_block = aws_vpc.vpc_tools.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "tools_to_app" {
  route_table_id = aws_route_table.tools.id
  destination_cidr_block = aws_vpc.vpc_app.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}