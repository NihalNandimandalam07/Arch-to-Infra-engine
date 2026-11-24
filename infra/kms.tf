# Engine KMS key: encrypts the engine's buckets, and later its DynamoDB table, SNS topic and logs.
# Service-specific grants (e.g. CloudWatch Logs) are added to the key policy as those services arrive.

data "aws_iam_policy_document" "engine_key" {
  statement {
    sid       = "EnableIAMPolicies"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "engine" {
  description             = "Encrypts data for the ${var.name_prefix} diagram-to-infrastructure engine"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.engine_key.json
}

resource "aws_kms_alias" "engine" {
  name          = "alias/${var.name_prefix}-engine"
  target_key_id = aws_kms_key.engine.key_id
}
