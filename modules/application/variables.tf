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

variable "instance_type" {
  description = "Instance type to use in the Launch Configuration"
}

variable "desired_capacity" {
  description = "Desired Capacity for number of instances running all the time"
}

variable "max_size" {
  description = "Maximum number of instances running all the time"
}

variable "min_size" {
  description = "Minimum number of instances running all the time"
}

variable "image_id" {
  description = "AMI image ID to use"
}
