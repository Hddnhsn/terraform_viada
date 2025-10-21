# Variables for IAM Configuration

variable "create_terraform_iam_policy" {
  description = "Create IAM policy for Terraform"
  type        = bool
  default     = false
}

variable "create_terraform_iam_user" {
  description = "Create IAM user for Terraform"
  type        = bool
  default     = false
}

variable "create_terraform_iam_role" {
  description = "Create IAM role for Terraform"
  type        = bool
  default     = false
}

variable "terraform_role_trusted_arns" {
  description = "List of ARNs allowed to assume the Terraform role"
  type        = list(string)
  default     = []
}
