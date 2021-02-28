###############################################################################
# Management VPC Output
###############################################################################
output "VPCManagement" {
  description = "The ID of the VPC."
  value       = aws_vpc.VPCManagement.id
}

output "BastionInstanceIP" {
  description = "Public IP of the bastion host."
  value       = aws_eip.EIPProdBastion.public_ip
}

output "ManagementDMZSubnetA" {
  description = "The ID of the DMZ Subnet A."
  value       = aws_subnet.ManagementDMZSubnetA.id
}

output "ManagementDMZSubnetB" {
  description = "The ID of the DMZ Subnet B."
  value       = aws_subnet.ManagementDMZSubnetB.id
}

output "ManagementPrivateSubnetA" {
  description = "The ID of the Private Subnet A."
  value       = aws_subnet.ManagementPrivateSubnetA.id
}

output "ManagementPrivateSubnetB" {
  description = "The ID of the Private Subnet B."
  value       = aws_subnet.ManagementPrivateSubnetB.id
}

output "RouteTableMgmtPrivate" {
  description = "The ID of the Private Routing Table."
  value       = aws_route_table.RouteTableMgmtPrivate.id
}

output "RouteTableMgmtDMZ" {
  description = "The ID of the DMZ Routing Table."
  value       = aws_route_table.RouteTableMgmtDMZ.id
}
