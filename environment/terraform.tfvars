###############################################################################
# Environment
###############################################################################
aws_account_id = "130541009828"
region         = "ap-southeast-2"

###############################################################################
# Base Network
###############################################################################
vpc_name          = "Production VPC"
environment       = "Production"
cidr_block        = "10.100.0.0/16"
bastionsshcidr    = "0.0.0.0/0"
managementcidr    = "10.10.0.0/16"
DMZSubnetACIDR    = "10.100.10.0/24"
DMZSubnetBCIDR    = "10.100.20.0/24"
AppPrivateSubnetA = "10.100.96.0/21"
AppPrivateSubnetB = "10.100.112.0/21"
DBPrivateSubnetA  = "10.100.192.0/21"
DBPrivateSubnetB  = "10.100.208.0/21"
