variable "region" {
  description = "AWS region for the state bucket and KMS key."
  type        = string
  default     = "us-east-1"
}

variable "allowed_account_ids" {
  description = "AWS account IDs this stack may be applied to. Guards against applying to the wrong account."
  type        = list(string)

  validation {
    condition     = length(var.allowed_account_ids) > 0 && alltrue([for id in var.allowed_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "allowed_account_ids must contain at least one 12-digit AWS account ID."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "a2i"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name_prefix))
    error_message = "name_prefix must be 2-21 chars: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep previous versions of state files before they expire."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_retention_days >= 30
    error_message = "Keep previous state versions for at least 30 days."
  }
}

variable "tags" {
  description = "Extra tags applied to all resources (merged with the standard project tags)."
  type        = map(string)
  default     = {}
}
