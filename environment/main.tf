###############################################################################
# Terraform main config
###############################################################################

### PLEASE UPDATE BACKEND BUCKET NAME AND REGION

terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 3.6.0"
  }
  backend "s3" {
    bucket  = "130541009828-build-state-bucket-tf-sandys" ### PLEASE UPDATE BACKEND BUCKET NAME
    key     = "terraform.environment.tfstate"             ### PLEASE UPDATE REGION
    region  = "ap-southeast-2"
    encrypt = "true"
  }
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  tags = {
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
}

###############################################################################
# VPCs
###############################################################################
module "productionvpc" {
  source = "../modules/productionvpc"

  region            = var.region
  vpc_name          = var.vpc_name
  environment       = var.environment
  productioncidr    = var.productioncidr
  bastionsshcidr    = var.bastionsshcidr
  managementcidr    = var.managementcidr
  DMZSubnetACIDR    = var.DMZSubnetACIDR
  DMZSubnetBCIDR    = var.DMZSubnetBCIDR
  AppPrivateSubnetA = var.AppPrivateSubnetA
  AppPrivateSubnetB = var.AppPrivateSubnetB
  DBPrivateSubnetA  = var.DBPrivateSubnetA
  DBPrivateSubnetB  = var.DBPrivateSubnetB
}

module "managementvpc" {
  source = "../modules/managementvpc"

  region                       = var.region
  managementvpcname            = var.managementvpcname
  environment                  = var.environment
  managementcidr               = var.managementcidr
  bastionsshcidr               = var.bastionsshcidr
  ManagementDMZSubnetACIDR     = var.ManagementDMZSubnetACIDR
  ManagementDMZSubnetBCIDR     = var.ManagementDMZSubnetBCIDR
  ManagementPrivateSubnetACIDR = var.ManagementPrivateSubnetACIDR
  ManagementPrivateSubnetBCIDR = var.ManagementPrivateSubnetBCIDR
  map_public_ip_on_launch      = var.map_public_ip_on_launch

  ec2keypairbastion   = var.ec2keypairbastion
  bastioninstancetype = var.bastioninstancetype

  ProductionVPC          = module.productionvpc.vpc_id
  ProductionCIDR         = var.productioncidr
  RouteTableProdPrivate  = module.productionvpc.route_table_prod_private_a
  RouteTableProdPrivateB = module.productionvpc.route_table_prod_private_b
  RouteTableProdPublic   = module.productionvpc.route_table_prod_public
}

module "iam" {
  source = "../modules/iam"

}

module "iam_password" {
  source = "../modules/iam_password"

  minimum_password_length      = var.minimum_password_length
  require_lowercase_characters = var.require_lowercase_characters
  require_numbers              = var.require_numbers
  require_uppercase_characters = var.require_uppercase_characters
  require_symbols              = var.require_symbols
  max_password_age             = var.max_password_age
  password_reuse_prevention    = var.password_reuse_prevention
}
