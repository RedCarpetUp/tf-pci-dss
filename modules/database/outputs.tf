###############################################################################
# Database Output
###############################################################################
output "rds_sg_id" {
  description = "The ID of the S3 CloudTrail bucket."
  value       = aws_security_group.rds_sg.id
}
