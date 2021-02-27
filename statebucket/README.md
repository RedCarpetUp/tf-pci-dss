# Initialisation

This layer is used to create a S3 bucket for remote state storage.

### Create

Update the `terraform.tfvars` file to include your required AWS account ID, environment and region. This is just for the state bucket and not for where you are deploying your code so you can choose to place the bucket in a location closer to you than the target for the build.

- Expecting that your AWS credentials are in order.

```bash
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

### Destroy

```bash
$ terraform destroy
```

When prompted, check the plan and then respond in the affirmative.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | The account ID you are building into. | string | n/a | yes |
| environment | The name of the environment, e.g. Production, Development, Staging, etc. | string | `"Development"` | no |
| region | The AWS region the state should reside in. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| state\_bucket\_id | The ID of the bucket to be used for state files. |
| state\_bucket\_region | The region the state bucket resides in. |
