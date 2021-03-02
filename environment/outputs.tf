###############################################################################
# Production VPC
###############################################################################
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.productionvpc.vpc_id
}

output "dmz_subnet_a" {
  description = "The ID of the DMZ Subnet A."
  value       = module.productionvpc.dmz_subnet_a
}

output "dmz_subnet_b" {
  description = "The ID of the DMZ Subnet B."
  value       = module.productionvpc.dmz_subnet_b
}

output "app_subnet_a" {
  description = "The ID of the App Subnet A."
  value       = module.productionvpc.app_subnet_a
}

output "app_subnet_b" {
  description = "The ID of the App Subnet B."
  value       = module.productionvpc.app_subnet_b
}

output "db_subnet_a" {
  description = "The ID of the DB Subnet A."
  value       = module.productionvpc.db_subnet_a
}

output "db_subnet_b" {
  description = "The ID of the DB Subnet B."
  value       = module.productionvpc.db_subnet_b
}

output "nacl_public" {
  description = "The ID of the Public NACL."
  value       = module.productionvpc.nacl_public
}

output "nacl_private" {
  description = "The ID of the Private NACL."
  value       = module.productionvpc.nacl_private
}

output "route_table_prod_public" {
  description = "The ID of the Public Routing Table."
  value       = module.productionvpc.route_table_prod_public
}

output "route_table_prod_private_a" {
  description = "The ID of the Private Routing Table A."
  value       = module.productionvpc.route_table_prod_private_a
}

output "route_table_prod_private_b" {
  description = "The ID of the Private Routing Table B."
  value       = module.productionvpc.route_table_prod_private_b
}

###############################################################################
# Management VPC Output
###############################################################################
output "VPCManagement" {
  description = "The ID of the VPC."
  value       = module.managementvpc.VPCManagement
}

output "BastionInstanceIP" {
  description = "Public IP of the bastion host."
  value       = module.managementvpc.BastionInstanceIP
}

output "ManagementDMZSubnetA" {
  description = "The ID of the DMZ Subnet A."
  value       = module.managementvpc.ManagementDMZSubnetA
}

output "ManagementDMZSubnetB" {
  description = "The ID of the DMZ Subnet B."
  value       = module.managementvpc.ManagementDMZSubnetB
}

output "ManagementPrivateSubnetA" {
  description = "The ID of the Private Subnet A."
  value       = module.managementvpc.ManagementPrivateSubnetA
}

output "ManagementPrivateSubnetB" {
  description = "The ID of the Private Subnet B."
  value       = module.managementvpc.ManagementPrivateSubnetB
}

output "RouteTableMgmtPrivate" {
  description = "The ID of the Private Routing Table."
  value       = module.managementvpc.RouteTableMgmtPrivate
}

output "RouteTableMgmtDMZ" {
  description = "The ID of the DMZ Routing Table."
  value       = module.managementvpc.RouteTableMgmtDMZ
}

###############################################################################
# IAM Output
###############################################################################
output "SysAdmin" {
  description = "The ID of the SysAdmin Group."
  value       = module.iam.SysAdmin
}

output "IAMAdminGroup" {
  description = "The ID of the IAMAdmin Group."
  value       = module.iam.IAMAdminGroup
}

output "InstanceOpsGroup" {
  description = "The ID of the InstanceOps Group."
  value       = module.iam.InstanceOpsGroup
}

output "ReadOnlyBillingGroup" {
  description = "The ID of the ReadOnlyBilling Group."
  value       = module.iam.ReadOnlyBillingGroup
}

output "ReadOnlyAdminGroup" {
  description = "The ID of the ReadOnlyAdmin Group."
  value       = module.iam.ReadOnlyAdminGroup
}

###############################################################################
# Centralized Logging Output
###############################################################################
output "s3cloudtrailbuckets" {
  description = "The ID of the S3 CloudTrail bucket."
  value       = module.logging.s3cloudtrailbuckets
}

###############################################################################
# RDS Output
###############################################################################
output "rds_sg_id" {
  description = "The ID of the S3 CloudTrail bucket."
  value       = module.database.rds_sg_id
}

###############################################################################
# Application Output
###############################################################################
output "loadbalancerdns" {
  description = "The DNS name of the load balancer."
  value       = module.application.loadbalancerdns
}
