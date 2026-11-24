locals {
  account_id = data.aws_caller_identity.current.account_id
  # S3 naming exception from DESIGN.md §16: <prefix>-<component>-<account>-<region>
  bucket_suffix = "${local.account_id}-${var.region}"
}

# Working files per job: jobs/<job_id>/{input,ir,analysis,terraform,validation}/...
module "artifacts_bucket" {
  source = "./modules/secure_bucket"

  name        = "${var.name_prefix}-artifacts-${local.bucket_suffix}"
  kms_key_arn = aws_kms_key.engine.arn

  current_version_expiration_days    = var.artifacts_expiration_days
  noncurrent_version_expiration_days = 30
}

# Write-once audit trail: IR, plan, reports, Terraform zip and approval decision per job.
module "evidence_bucket" {
  source = "./modules/secure_bucket"

  name        = "${var.name_prefix}-evidence-${local.bucket_suffix}"
  kms_key_arn = aws_kms_key.engine.arn

  object_lock = {
    mode = var.evidence_lock_mode
    days = var.evidence_retention_days
  }
}
