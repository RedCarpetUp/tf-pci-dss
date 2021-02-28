###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "AWS Account ID."
}

variable "region" {
  description = "Default Region."
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "Name of the environment for the deployment, e.g. Integration, PreProduction, Production, QA, Staging, Test."
}

variable "productioncidr" {
  description = "Production VPC CIDR block."
}

variable "bastionsshcidr" {
  description = "Bastion CIDR block."
}

variable "managementcidr" {
  description = "Management CIDR block."
}

###############################################################################
# Variables - Production VPC
###############################################################################
variable "vpc_name" {
  description = "Production VPC Name"
}

variable "DMZSubnetACIDR" {
  description = "DMZ CIDR block A."
}

variable "DMZSubnetBCIDR" {
  description = "DMZ CIDR block B."
}

variable "AppPrivateSubnetA" {
  description = "App CIDR block A."
}

variable "AppPrivateSubnetB" {
  description = "App CIDR block B."
}

variable "DBPrivateSubnetA" {
  description = "DB CIDR block A."
}

variable "DBPrivateSubnetB" {
  description = "DB CIDR block B."
}

###############################################################################
# Variables - Management VPC
###############################################################################
variable "managementvpcname" {
  description = "Management VPC Name"
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

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false."
}
