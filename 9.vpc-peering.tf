data "aws_vpc" "ansible_vpc" {
  id = "vpc-0f5de68ee87a09f00" #ansible-controller
}

data "aws_route_table" "ansible_vpc_rt" {
  subnet_id = "subnet-0503f01475ccf8673" #ansible-controller
  #If subnet_id giving errors use route table id as below
  #route_table_id = data.aws_route_table.ansible_vpc_rt.id
}

resource "aws_vpc_peering_connection" "ansible-vpc-peering" {
  peer_vpc_id = data.aws_vpc.ansible_vpc.id
  vpc_id      = aws_vpc.default.id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "Ansible-${var.vpc_name}-Peering"
  }
}

resource "aws_route" "peering-to-ansible-vpc" {
  route_table_id            = aws_route_table.terraform-public.id
  destination_cidr_block    = "10.1.0.0/16" # ansible-controller
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id
  #depends_on                = [aws_route_table.terraform-public]
}

resource "aws_route" "peering-to-client-vpc" {
  route_table_id            = data.aws_route_table.ansible_vpc_rt.id
  destination_cidr_block    = "10.37.0.0/16" #client
  vpc_peering_connection_id = aws_vpc_peering_connection.ansible-vpc-peering.id
  #depends_on                = [aws_route_table.terraform-public]
}