###############################################################################
# Production VPC Output
###############################################################################
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "dmz_subnet_a" {
  description = "The ID of the DMZ Subnet A."
  value       = aws_subnet.DMZSubnetACIDR.id
}

output "dmz_subnet_b" {
  description = "The ID of the DMZ Subnet B."
  value       = aws_subnet.DMZSubnetBCIDR.id
}

output "app_subnet_a" {
  description = "The ID of the App Subnet A."
  value       = aws_subnet.AppPrivateSubnetA.id
}

output "app_subnet_b" {
  description = "The ID of the App Subnet B."
  value       = aws_subnet.AppPrivateSubnetB.id
}

output "db_subnet_a" {
  description = "The ID of the DB Subnet A."
  value       = aws_subnet.DBPrivateSubnetA.id
}

output "db_subnet_b" {
  description = "The ID of the DB Subnet B."
  value       = aws_subnet.DBPrivateSubnetB.id
}

output "nacl_public" {
  description = "The ID of the Public NACL."
  value       = aws_network_acl.NACLPublic.id
}

output "nacl_private" {
  description = "The ID of the Private NACL."
  value       = aws_network_acl.NACLPrivate.id
}

output "route_table_prod_public" {
  description = "The ID of the Public Routing Table."
  value       = aws_route_table.RouteTableMain.id
}

output "route_table_prod_private_a" {
  description = "The ID of the Private Routing Table A."
  value       = aws_route_table.RouteTableProdPrivateA.id
}

output "route_table_prod_private_b" {
  description = "The ID of the Private Routing Table B."
  value       = aws_route_table.RouteTableProdPrivateB.id
}
