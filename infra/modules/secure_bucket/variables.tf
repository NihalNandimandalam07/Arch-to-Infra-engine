variable "name" {
  description = "Globally unique bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "Bucket name must be 3-63 chars of lowercase letters, digits and hyphens."
  }
}

variable "kms_key_arn" {
  description = "ARN of the customer-managed KMS key used for default encryption. Uploads using any other key are denied."
  type        = string
}

variable "object_lock" {
  description = "Enable S3 Object Lock with a default retention. null = no Object Lock. Can only be enabled at bucket creation."
  type = object({
    mode = string # GOVERNANCE or COMPLIANCE
    days = number
  })
  default = null

  validation {
    condition     = var.object_lock == null ? true : contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock.mode) && var.object_lock.days >= 1
    error_message = "object_lock.mode must be GOVERNANCE or COMPLIANCE and object_lock.days must be >= 1."
  }
}

variable "current_version_expiration_days" {
  description = "Expire current object versions after this many days. null = keep forever."
  type        = number
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Delete previous object versions after this many days. null = keep forever."
  type        = number
  default     = null
}
