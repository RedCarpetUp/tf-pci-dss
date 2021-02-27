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
