# 000base

This layer creates the Networking resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | The account ID you are building into. | string | n/a | yes |
| environment | The name of the environment, e.g. Production, Development, etc. | string | `"Development"` | no |
| region | The AWS region the state should reside in. | string | `"ap-southeast-2"` | yes |
| vpc\_name | Name for the VPC. | string | `"BaseNetwork"` | yes |
| cidr\_range | CIDR range for the VPC. | string | n/a | yes |
| private\_cidr\_ranges | An array of CIDR ranges to use for private subnets. | string | n/a | yes |
| public\_cidr\_ranges | An array of CIDR ranges to use for public subnets. | string | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the VPC. |
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
