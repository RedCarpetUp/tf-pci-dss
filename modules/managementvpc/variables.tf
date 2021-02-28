###############################################################################
# Variables - Management VPC
###############################################################################
variable "region" {
  description = "Default Region."
}

variable "environment" {
  description = "Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test."
}

variable "managementvpcname" {
  description = "Management VPC Name"
}

variable "managementcidr" {
  description = "Management VPC CIDR block."
}

variable "bastionsshcidr" {
  description = "Bastion CIDR block."
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false."
}

variable "ManagementDMZSubnetACIDR" {
  description = "DMZ CIDR block A."
}

variable "ManagementDMZSubnetBCIDR" {
  description = "DMZ CIDR block B."
}

variable "ManagementPrivateSubnetACIDR" {
  description = "Private CIDR block A."
}

variable "ManagementPrivateSubnetBCIDR" {
  description = "Private CIDR block B."
}

variable "ec2keypairbastion" {
  description = "Bastion Host Key Pair."
}

variable "bastioninstancetype" {
  description = "Bastion Host Instance Type."
}

variable "ProductionVPC" {
  description = "Production VPC CIDR ID."
}

variable "ProductionCIDR" {
  description = "Production VPC CIDR block."
}

variable "RouteTableProdPublic" {
  description = "Production VPC Public Route Table."
}

variable "RouteTableProdPrivate" {
  description = "Production VPC Private Route Table A."
}

variable "RouteTableProdPrivateB" {
  description = "Production VPC Private Route Table B."
}
