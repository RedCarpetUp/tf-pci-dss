###############################################################################
# IAM Output
###############################################################################
output "SysAdmin" {
  description = "The ID of the SysAdmin Group."
  value       = aws_iam_group.SysAdmin.id
}

output "IAMAdminGroup" {
  description = "The ID of the IAMAdmin Group."
  value       = aws_iam_group.IAMAdminGroup.id
}

output "InstanceOpsGroup" {
  description = "The ID of the InstanceOps Group."
  value       = aws_iam_group.InstanceOpsGroup.id
}

output "ReadOnlyBillingGroup" {
  description = "The ID of the ReadOnlyBilling Group."
  value       = aws_iam_group.ReadOnlyBillingGroup.id
}

output "ReadOnlyAdminGroup" {
  description = "The ID of the ReadOnlyAdmin Group."
  value       = aws_iam_group.ReadOnlyAdminGroup.id
}
