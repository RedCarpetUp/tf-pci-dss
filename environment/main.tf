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
# VPC
###############################################################################
module "productionvpc" {
  source = "../modules/productionvpc"

  region            = var.region
  vpc_name          = var.vpc_name
  environment       = var.environment
  cidr_block        = var.cidr_block
  bastionsshcidr    = var.bastionsshcidr
  managementcidr    = var.managementcidr
  DMZSubnetACIDR    = var.DMZSubnetACIDR
  DMZSubnetBCIDR    = var.DMZSubnetBCIDR
  AppPrivateSubnetA = var.AppPrivateSubnetA
  AppPrivateSubnetB = var.AppPrivateSubnetB
  DBPrivateSubnetA  = var.DBPrivateSubnetA
  DBPrivateSubnetB  = var.DBPrivateSubnetB
}
