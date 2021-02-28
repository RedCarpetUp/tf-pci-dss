###############################################################################
# IAM
###############################################################################
resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length      = var.minimum_password_length
  require_lowercase_characters = var.require_lowercase_characters
  require_numbers              = var.require_numbers
  require_uppercase_characters = var.require_uppercase_characters
  require_symbols              = var.require_symbols
  max_password_age             = var.max_password_age
  password_reuse_prevention    = var.password_reuse_prevention
}
