###############################################################################
# Data Source
###############################################################################
data "aws_availability_zones" "available" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*"
  owners     = ["099720109477"]
}

###############################################################################
# VPC
###############################################################################
resource "aws_vpc" "VPCManagement" {
  cidr_block           = var.managementcidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.managementvpcname
    Environment = var.environment
  }
}

###############################################################################
# Security Groups
###############################################################################
resource "aws_security_group" "SecurityGroupBastion" {
  description = "SG for Bastion Instances"
  vpc_id      = aws_vpc.VPCManagement.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastionsshcidr]
  }

  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-ssh-access-from-bastion"
    Environment = var.environment
  }
}

###############################################################################
# Subnets
###############################################################################
resource "aws_subnet" "ManagementDMZSubnetA" {
  vpc_id                  = aws_vpc.VPCManagement.id
  cidr_block              = var.ManagementDMZSubnetACIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "Management DMZ Subnet A"
  }
}

resource "aws_subnet" "ManagementDMZSubnetB" {
  vpc_id                  = aws_vpc.VPCManagement.id
  cidr_block              = var.ManagementDMZSubnetBCIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name        = "Production DMZ Subnet B"
    Environment = var.environment
  }
}

resource "aws_subnet" "ManagementPrivateSubnetA" {
  vpc_id            = aws_vpc.VPCManagement.id
  cidr_block        = var.ManagementPrivateSubnetACIDR
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "Management Private Subnet A"
    Environment = var.environment
  }
}

resource "aws_subnet" "ManagementPrivateSubnetB" {
  vpc_id            = aws_vpc.VPCManagement.id
  cidr_block        = var.ManagementPrivateSubnetBCIDR
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "Management Private Subnet B"
    Environment = var.environment
  }
}

###############################################################################
# IGW
###############################################################################
resource "aws_internet_gateway" "IGWManagement" {
  vpc_id = aws_vpc.VPCManagement.id

  tags = {
    Name        = "igw-management"
    Environment = var.environment
  }
}

###############################################################################
# Route Table
###############################################################################
resource "aws_route_table" "RouteTableMgmtDMZ" {
  vpc_id = aws_vpc.VPCManagement.id

  tags = {
    Name = "Management DMZ Route"
  }
}

resource "aws_route_table" "RouteTableMgmtPrivate" {
  vpc_id = aws_vpc.VPCManagement.id

  tags = {
    Name = "Management Private Route"
  }
}

###############################################################################
# Route
###############################################################################
resource "aws_route" "RouteMgmtIGW" {
  route_table_id         = aws_route_table.RouteTableMgmtDMZ.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGWManagement.id
}

###############################################################################
# Table Association
###############################################################################
resource "aws_route_table_association" "RouteAssocMgmtDMZA" {
  subnet_id      = aws_subnet.ManagementDMZSubnetA.id
  route_table_id = aws_route_table.RouteTableMgmtDMZ.id
}

resource "aws_route_table_association" "RouteAssocMgmtDMZB" {
  subnet_id      = aws_subnet.ManagementDMZSubnetB.id
  route_table_id = aws_route_table.RouteTableMgmtDMZ.id
}

resource "aws_route_table_association" "RouteAssocMgmtPrivA" {
  subnet_id      = aws_subnet.ManagementPrivateSubnetA.id
  route_table_id = aws_route_table.RouteTableMgmtPrivate.id
}

resource "aws_route_table_association" "AppPrivateSubnetAssociationB" {
  subnet_id      = aws_subnet.ManagementPrivateSubnetA.id
  route_table_id = aws_route_table.RouteTableMgmtPrivate.id
}

###############################################################################
# ENI
###############################################################################
resource "aws_network_interface" "ENIProductionBastion" {
  subnet_id       = aws_subnet.ManagementDMZSubnetA.id
  security_groups = [aws_security_group.SecurityGroupBastion.id]

  tags = {
    Network = "MgmtBastionDevice"
  }
}

###############################################################################
# EC2 Instance - Bastion
###############################################################################
resource "aws_instance" "MgmtBastionInstance" {
  ami           = data.aws_ami.ami.image_id
  instance_type = var.bastioninstancetype
  key_name      = var.ec2keypairbastion

  network_interface {
    network_interface_id = aws_network_interface.ENIProductionBastion.id
    device_index         = 0
  }

  user_data_base64 = base64encode(local.user_data)

  tags = {
    Name = "Bastion Server"
  }
}

locals {
  user_data = <<EOF
#!/bin/bash
yum update -y
EOF
}

###############################################################################
# EIP
###############################################################################
resource "aws_eip" "EIPProdBastion" {
  vpc      = true
  instance = aws_instance.MgmtBastionInstance.id
}

resource "aws_eip" "EIPProdNAT" {
  vpc = true
}

###############################################################################
# NATGW
###############################################################################
resource "aws_nat_gateway" "NATGateway" {
  allocation_id = aws_eip.EIPProdNAT.id
  subnet_id     = aws_subnet.ManagementDMZSubnetA.id
}

###############################################################################
# VPC Peering
###############################################################################
resource "aws_vpc_peering_connection" "PeeringConnectionProduction" {
  peer_vpc_id = var.ProductionVPC
  vpc_id      = aws_vpc.VPCManagement.id
  auto_accept = true

  tags = {
    Name        = "vpc-peer-production-management"
    Environment = var.environment
  }
}

###############################################################################
# Route - VPC Peering
###############################################################################
resource "aws_route" "RouteMgmtProdPrivate" {
  route_table_id            = aws_route_table.RouteTableMgmtPrivate.id
  destination_cidr_block    = var.ProductionCIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.PeeringConnectionProduction.id
}

resource "aws_route" "RouteMgmtNGW" {
  route_table_id         = aws_route_table.RouteTableMgmtPrivate.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NATGateway.id
}

resource "aws_route" "RouteProdMgmt" {
  route_table_id            = var.RouteTableProdPrivate
  destination_cidr_block    = var.managementcidr
  vpc_peering_connection_id = aws_vpc_peering_connection.PeeringConnectionProduction.id
}

resource "aws_route" "RouteProdMgmtB" {
  route_table_id            = var.RouteTableProdPrivateB
  destination_cidr_block    = var.managementcidr
  vpc_peering_connection_id = aws_vpc_peering_connection.PeeringConnectionProduction.id
}

resource "aws_route" "RouteProdMgmtPublic" {
  route_table_id            = var.RouteTableProdPublic
  destination_cidr_block    = var.managementcidr
  vpc_peering_connection_id = aws_vpc_peering_connection.PeeringConnectionProduction.id
}

resource "aws_route" "RouteMgmtProdDMZ" {
  route_table_id            = aws_route_table.RouteTableMgmtDMZ.id
  destination_cidr_block    = var.ProductionCIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.PeeringConnectionProduction.id
}
