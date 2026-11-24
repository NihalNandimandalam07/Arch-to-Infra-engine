output "engine_kms_key_arn" {
  description = "ARN of the engine KMS key."
  value       = aws_kms_key.engine.arn
}

output "engine_kms_alias" {
  description = "Alias of the engine KMS key."
  value       = aws_kms_alias.engine.name
}

output "artifacts_bucket_name" {
  description = "Bucket for per-job working files."
  value       = module.artifacts_bucket.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = module.artifacts_bucket.arn
}

output "evidence_bucket_name" {
  description = "Object Lock bucket for the per-job audit trail."
  value       = module.evidence_bucket.id
}

output "evidence_bucket_arn" {
  description = "ARN of the evidence bucket."
  value       = module.evidence_bucket.arn
}
