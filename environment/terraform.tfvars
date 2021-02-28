###############################################################################
# Environment
###############################################################################
aws_account_id = "130541009828"
region         = "ap-southeast-2"

###############################################################################
# VPC Common
###############################################################################
environment    = "Production"
productioncidr = "10.100.0.0/16"
bastionsshcidr = "0.0.0.0/0"
managementcidr = "10.10.0.0/16"

###############################################################################
# Production VPC
###############################################################################
vpc_name          = "Production VPC"
DMZSubnetACIDR    = "10.100.10.0/24"
DMZSubnetBCIDR    = "10.100.20.0/24"
AppPrivateSubnetA = "10.100.96.0/21"
AppPrivateSubnetB = "10.100.112.0/21"
DBPrivateSubnetA  = "10.100.192.0/21"
DBPrivateSubnetB  = "10.100.208.0/21"

###############################################################################
# Management VPC
###############################################################################
managementvpcname            = "Management VPC"
ManagementDMZSubnetACIDR     = "10.10.1.0/24"
ManagementDMZSubnetBCIDR     = "10.10.2.0/24"
ManagementPrivateSubnetACIDR = "10.10.20.0/24"
ManagementPrivateSubnetBCIDR = "10.10.30.0/24"
ec2keypairbastion            = "ans"
bastioninstancetype          = "m4.large"
map_public_ip_on_launch      = true

###############################################################################
# IAM Password Policy
###############################################################################
minimum_password_length      = 7
require_lowercase_characters = true
require_numbers              = true
require_uppercase_characters = true
require_symbols              = true
max_password_age             = 90
password_reuse_prevention    = 4
