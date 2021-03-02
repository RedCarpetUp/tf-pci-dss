## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | The account ID you are building into. | string | n/a | yes |
| region | The AWS region the state should reside in. | string | n/a | yes |
| environment | The name of the environment, e.g. Production, Development, etc. | string | n/a | no |
| productioncidr | Production VPC CIDR block. | string | n/a | yes |
| bastionsshcidr | Bastion CIDR block. | string | n/a | yes |
| managementcidr | Management CIDR block. | string | n/a | yes |
| vpc_name | Production VPC Name. | string | n/a | yes |
| DMZSubnetACIDR | DMZ CIDR block A. | string | n/a | yes |
| DMZSubnetBCIDR | DMZ CIDR block B. | string | n/a | yes |
| AppPrivateSubnetA | App CIDR block A. | string | n/a | yes |
| AppPrivateSubnetB | App CIDR block B. | string | n/a | yes |
| DBPrivateSubnetA | DB CIDR block A. | string | n/a | yes |
| DBPrivateSubnetB | DB CIDR block B. | string | n/a | yes |
| managementvpcname | Management VPC Name. | string | n/a | yes |
| ManagementDMZSubnetACIDR | DMZ CIDR block A. | string | n/a | yes |
| ManagementDMZSubnetBCIDR | DMZ CIDR block B. | string | n/a | yes |
| ManagementPrivateSubnetACIDR | Private CIDR block A. | string | n/a | yes |
| ManagementPrivateSubnetBCIDR | Private CIDR block B. | string | n/a | yes |
| ec2keypairbastion | Bastion Host Key Pair. | string | n/a | yes |
| bastioninstancetype | Bastion Host Instance Type. | string | n/a | yes |
| map_public_ip_on_launch | Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false. | bool | n/a | yes |
| minimum_password_length | Minimum password length. (8-128 characters) | number | 7 | yes |
| require_lowercase_characters | Password requirement of at least one lowercase character. | bool | n/a | yes |
| require_numbers | Password requirement of at least one number. | bool | n/a | yes |
| require_uppercase_characters | Password requirement of at least one uppercase character. | bool | n/a | yes |
| require_symbols | Password requirement of at least one nonalphanumeric character. | bool | n/a | yes |
| max_password_age | Maximum age for passwords, in number of days. (90-365 days) | number | 90 | yes |
| password_reuse_prevention | Number of previous passwords to remember. (1-24 passwords) | string | n/a | yes |
| BucketName | The name of a new S3 bucket for logging CloudTrail events. The name must be a globally unique value and must be in lowercase letters. | string | n/a | yes |
| CloudTrailName | The name of a new S3 bucket for logging CloudTrail events. The name must be a globally unique value and must be in lowercase letters. | string | n/a | yes |
| rds_name | Name of the RDS cluster. | string | n/a | yes |
| rds_count | Number of RDS instances to deploy. | string | n/a | yes |
| database_name | Database Name. | string | n/a | yes |
| master_username | Master Username for the Database. | string | n/a | yes |
| engine | Database Engine to use. | string | n/a | yes |
| engine_version | Database Engine version to use. | string | n/a | yes |
| instance_class | Database Instance class to use. | string | n/a | yes |
| instance_type | Instance type to use in the Launch Configuration. | string | n/a | yes |
| desired_capacity | Desired Capacity for number of instances running all the time. | number | n/a | yes |
| max_size | Maximum number of instances running all the time. | number | n/a | yes |
| min_size | Minimum number of instances running all the time. | number | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the Production VPC. |
| dmz_subnet_a | The ID of the DMZ Subnet A. |
| dmz_subnet_b | The ID of the DMZ Subnet B. |
| app_subnet_a | The ID of the App Subnet A. |
| app_subnet_b | The ID of the App Subnet B. |
| db_subnet_a | The ID of the DB Subnet A. |
| db_subnet_b | The ID of the DB Subnet B. |
| nacl_public | The ID of the Public NACL. |
| nacl_private | The ID of the Private NACL. |
| route_table_prod_public | The ID of the Public Routing Table. |
| route_table_prod_private_a | The ID of the Private Routing Table A. |
| route_table_prod_private_b | The ID of the Private Routing Table B. |
| VPCManagement | The ID of the Management VPC. |
| BastionInstanceIP | Public IP of the bastion host. |
| ManagementDMZSubnetA | The ID of the DMZ Subnet A. |
| ManagementDMZSubnetB | The ID of the DMZ Subnet B. |
| ManagementPrivateSubnetA | The ID of the Private Subnet A. |
| ManagementPrivateSubnetB | The ID of the Private Subnet B. |
| RouteTableMgmtPrivate | The ID of the Private Routing Table. |
| RouteTableMgmtDMZ | The ID of the Public Routing Table A. |
| SysAdmin | The ID of the SysAdmin Group. |
| IAMAdminGroup | The ID of the IAMAdmin Group. |
| InstanceOpsGroup | The ID of the InstanceOps Group. |
| ReadOnlyBillingGroup | The ID of the ReadOnlyBilling Group. |
| ReadOnlyAdminGroup | The ID of the ReadOnlyAdmin Group. |
| s3cloudtrailbuckets | The ID of the S3 CloudTrail bucket. |
| rds_sg_id | The ID of the S3 CloudTrail bucket. |
| loadbalancerdns | The DNS name of the load balancer. |
