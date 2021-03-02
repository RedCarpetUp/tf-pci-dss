###############################################################################
# Variables - IAM
###############################################################################
variable "BucketName" {
  description = "The name of a new S3 bucket for logging CloudTrail events. The name must be a globally unique value and must be in lowercase letters."
}

variable "account_id" {
  description = "The AWS Account ID of the user."
}

variable "region" {
  description = "The AWS Account region."
}
