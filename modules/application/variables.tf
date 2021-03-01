###############################################################################
# Variables - IAM
###############################################################################
variable "environment" {
  description = "The name of the environment."
}

variable "ProductionVPC" {
  description = "The Production VPC where DB is going to be deployed."
}

variable "ProductionCIDR" {
  description = "The Production VPC CIDR."
}

variable "region" {
  description = "The region for the DB to be deployed in."
}

variable "DMZSubnetA" {
  description = "DMZ subnet A."
}

variable "DMZSubnetB" {
  description = "DMZ subnet B."
}

variable "AppPrivateSubnetA" {
  description = "App subnet A."
}

variable "AppPrivateSubnetB" {
  description = "App subnet B."
}

variable "rds_sg_id" {
  description = "The RDS security group ID."
}

variable "managementcidr" {
  description = "Management VPC CIDR block."
}
