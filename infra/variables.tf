variable "region" {
  description = "AWS region for the engine."
  type        = string
  default     = "us-east-1"
}

variable "allowed_account_ids" {
  description = "AWS account IDs this stack may be applied to."
  type        = list(string)

  validation {
    condition     = length(var.allowed_account_ids) > 0 && alltrue([for id in var.allowed_account_ids : can(regex("^[0-9]{12}$", id))])
    error_message = "allowed_account_ids must contain at least one 12-digit AWS account ID."
  }
}

variable "name_prefix" {
  description = "Prefix for the engine's own resource names (DESIGN.md §16.3)."
  type        = string
  default     = "a2i"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.name_prefix)) && length(var.name_prefix) <= 12
    error_message = "name_prefix must be up to 12 chars: lowercase letters, digits and single hyphens, starting with a letter."
  }
}

variable "artifacts_expiration_days" {
  description = "Days to keep working files (diagrams, IRs, generated Terraform, reports) in the artifacts bucket. Evidence copies are kept separately."
  type        = number
  default     = 90

  validation {
    condition     = var.artifacts_expiration_days >= 7
    error_message = "Keep artifacts for at least 7 days."
  }
}

variable "evidence_lock_mode" {
  description = "Object Lock mode for the evidence bucket. GOVERNANCE can be bypassed by privileged admins (PoC); COMPLIANCE cannot be bypassed by anyone, including root."
  type        = string
  default     = "GOVERNANCE"

  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.evidence_lock_mode)
    error_message = "evidence_lock_mode must be GOVERNANCE or COMPLIANCE."
  }
}

variable "evidence_retention_days" {
  description = "Default Object Lock retention for evidence objects."
  type        = number
  default     = 90

  validation {
    condition     = var.evidence_retention_days >= 1
    error_message = "evidence_retention_days must be at least 1."
  }
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
