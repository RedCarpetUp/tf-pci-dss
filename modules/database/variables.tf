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

variable "rds_count" {
  description = "Number of RDS instances to deploy"
}

variable "rds_name" {
  description = "Name of the RDS cluster"
}

variable "database_name" {
  description = "Database Name"
}

variable "master_username" {
  description = "Master Username for the Database"
}

variable "engine" {
  description = "Database Engine to use"
}

variable "engine_version" {
  description = "Database Engine version to use"
}

variable "instance_class" {
  description = "Database Instance class to use"
}
