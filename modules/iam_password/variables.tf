###############################################################################
# Variables - IAM Password Policy
###############################################################################
variable "minimum_password_length" {
  description = "Minimum password length. (8-128 characters)"
  default     = "7"
}

variable "require_lowercase_characters" {
  description = "Password requirement of at least one lowercase character."
}

variable "require_numbers" {
  description = "Password requirement of at least one number."
}

variable "require_uppercase_characters" {
  description = "Password requirement of at least one uppercase character."
}

variable "require_symbols" {
  description = "Password requirement of at least one nonalphanumeric character."
}

variable "max_password_age" {
  description = "Maximum age for passwords, in number of days. (90-365 days)"
  default     = "90"
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords to remember. (1-24 passwords)"
}
