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

variable "DB_subnetA" {
  description = "DB subnet A."
}

variable "DB_subnetB" {
  description = "DB subnet B."
}
