###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "The account ID you are building into."
  type        = string
}

variable "environment" {
  description = "The name of the environment, e.g. Production, Development, etc."
  type        = string
  default     = "Development"
}

variable "region" {
  description = "The AWS region the state should reside in."
  type        = string
}
