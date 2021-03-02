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
    key     = "terraform.environment.tfstate"
    region  = "ap-southeast-2" ### PLEASE UPDATE REGION
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

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

###############################################################################
# Modules
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
  ec2keypairbastion            = var.ec2keypairbastion
  bastioninstancetype          = var.bastioninstancetype

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

module "logging" {
  source = "../modules/centralized-logging"

  BucketName     = var.BucketName
  account_id     = data.aws_caller_identity.current.account_id
  region         = data.aws_region.current.name
  CloudTrailName = var.CloudTrailName
}

module "database" {
  source = "../modules/database"

  database_name   = var.database_name
  master_username = var.master_username
  engine          = var.engine
  engine_version  = var.engine_version
  rds_name        = var.rds_name
  rds_count       = var.rds_count
  instance_class  = var.instance_class
  environment     = var.environment
  ProductionVPC   = module.productionvpc.vpc_id
  ProductionCIDR  = var.productioncidr
  DB_subnetA      = module.productionvpc.db_subnet_a
  DB_subnetB      = module.productionvpc.db_subnet_b
  region          = var.region

  depends_on = [module.productionvpc]
}

module "application" {
  source = "../modules/application"

  environment       = var.environment
  ProductionVPC     = module.productionvpc.vpc_id
  ProductionCIDR    = var.productioncidr
  region            = var.region
  DMZSubnetA        = module.productionvpc.dmz_subnet_a
  DMZSubnetB        = module.productionvpc.dmz_subnet_b
  AppPrivateSubnetA = module.productionvpc.app_subnet_a
  AppPrivateSubnetB = module.productionvpc.app_subnet_b
  rds_sg_id         = module.database.rds_sg_id
  managementcidr    = var.managementcidr
  instance_type     = var.instance_type
  desired_capacity  = var.desired_capacity
  max_size          = var.max_size
  min_size          = var.min_size
  image_id          = data.aws_ami.ami.id

  depends_on = [module.productionvpc, module.database]
}
