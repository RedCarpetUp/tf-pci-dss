###############################################################################
# Data Source
###############################################################################
data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

###############################################################################
# VPC
###############################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.productioncidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Environment = var.environment
  }
}

###############################################################################
# Security Groups
###############################################################################
resource "aws_security_group" "SecurityGroupMgmtBastion" {
  description = "Allow Bastion from Management Network"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastionsshcidr]
  }

  tags = {
    Name        = "sg-ssh-access-from-management-vpc"
    Environment = var.environment
  }
}

###############################################################################
# Subnets
###############################################################################
resource "aws_subnet" "DMZSubnetACIDR" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.DMZSubnetACIDR
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "Production DMZ Subnet A"
    Environment = var.environment
  }
}

resource "aws_subnet" "DMZSubnetBCIDR" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.DMZSubnetBCIDR
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "Production DMZ Subnet B"
    Environment = var.environment
  }
}

resource "aws_subnet" "AppPrivateSubnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.AppPrivateSubnetA
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "Production App Subnet A"
    Environment = var.environment
  }
}

resource "aws_subnet" "AppPrivateSubnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.AppPrivateSubnetB
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "Production App Subnet B"
    Environment = var.environment
  }
}

resource "aws_subnet" "DBPrivateSubnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.DBPrivateSubnetA
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "Production DB Subnet A"
    Environment = var.environment
  }
}

resource "aws_subnet" "DBPrivateSubnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.DBPrivateSubnetB
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "Production DB Subnet B"
    Environment = var.environment
  }
}

###############################################################################
# IGW
###############################################################################
resource "aws_internet_gateway" "IGWProd" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "igw-production"
    Environment = var.environment
  }
}

###############################################################################
# NACL
###############################################################################
resource "aws_network_acl" "NACLPublic" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.DMZSubnetACIDR.id, aws_subnet.DMZSubnetBCIDR.id]
}

resource "aws_network_acl" "NACLPrivate" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.AppPrivateSubnetA.id, aws_subnet.AppPrivateSubnetB.id, aws_subnet.DBPrivateSubnetA.id, aws_subnet.DBPrivateSubnetB.id]
}

###############################################################################
# Route Table
###############################################################################
resource "aws_route_table" "RouteTableMain" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Production DMZ Route"
  }
}

resource "aws_route_table" "RouteTableProdPrivateA" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Production Private Route A"
  }
}

resource "aws_route_table" "RouteTableProdPrivateB" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Production Private Route B"
  }
}

###############################################################################
# EIP
###############################################################################
resource "aws_eip" "EIPProdNatA" {
  vpc = true
}

resource "aws_eip" "EIPProdNatB" {
  vpc = true
}

###############################################################################
# NATGW
###############################################################################
resource "aws_nat_gateway" "NATGatewaySubnetA" {
  allocation_id = aws_eip.EIPProdNatA.id
  subnet_id     = aws_subnet.DMZSubnetACIDR.id
}

resource "aws_nat_gateway" "NATGatewaySubnetB" {
  allocation_id = aws_eip.EIPProdNatB.id
  subnet_id     = aws_subnet.DMZSubnetBCIDR.id
}

###############################################################################
# Route
###############################################################################
resource "aws_route" "RouteProdIGW" {
  route_table_id         = aws_route_table.RouteTableMain.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGWProd.id
}

resource "aws_route" "RouteProdPrivateNatGatewayA" {
  route_table_id         = aws_route_table.RouteTableProdPrivateA.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NATGatewaySubnetA.id
}

resource "aws_route" "RouteProdPrivateNatGatewayB" {
  route_table_id         = aws_route_table.RouteTableProdPrivateB.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NATGatewaySubnetB.id
}

###############################################################################
# Table Association
###############################################################################
resource "aws_route_table_association" "RouteAssocProdDMZA" {
  subnet_id      = aws_subnet.DMZSubnetACIDR.id
  route_table_id = aws_route_table.RouteTableMain.id
}

resource "aws_route_table_association" "RouteAssocProdDMZB" {
  subnet_id      = aws_subnet.DMZSubnetBCIDR.id
  route_table_id = aws_route_table.RouteTableMain.id
}

resource "aws_route_table_association" "AppPrivateSubnetAssociationA" {
  subnet_id      = aws_subnet.AppPrivateSubnetA.id
  route_table_id = aws_route_table.RouteTableProdPrivateA.id
}

resource "aws_route_table_association" "AppPrivateSubnetAssociationB" {
  subnet_id      = aws_subnet.AppPrivateSubnetB.id
  route_table_id = aws_route_table.RouteTableProdPrivateB.id
}

resource "aws_route_table_association" "RouteAssocDBPrivateA" {
  subnet_id      = aws_subnet.DBPrivateSubnetA.id
  route_table_id = aws_route_table.RouteTableProdPrivateA.id
}

resource "aws_route_table_association" "RouteAssocDBPrivateB" {
  subnet_id      = aws_subnet.DBPrivateSubnetB.id
  route_table_id = aws_route_table.RouteTableProdPrivateB.id
}

###############################################################################
# NACL Rules
###############################################################################
resource "aws_network_acl_rule" "NACLRuleAllowAllTCPInternal" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
  from_port      = 1
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowBastionSSHAccessPrivate" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.bastionsshcidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "NACLRuleAllowMgmtAccessSSHtoPrivate" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 125
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.managementcidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "NACLRuleAllowReturnTCPPriv" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowALLfromPrivEgress" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowAllTCPInternalEgress" {
  network_acl_id = aws_network_acl.NACLPrivate.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowALLEgressPublic" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowAllReturnTCP" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowHTTPfromProd" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "NACLRuleAllowBastionSSHAccessPublic" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 210
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.managementcidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "NACLRuleAllowEgressReturnTCP" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "NACLRuleAllowHTTPSPublic" {
  network_acl_id = aws_network_acl.NACLPublic.id
  rule_number    = 300
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  to_port        = 443
}
