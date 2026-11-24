provider "aws" {
  region = var.region

  # Refuse to run against any account other than the intended one.
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.tags, {
      Project   = "arch-to-infra-engine"
      Component = "bootstrap"
      ManagedBy = "terraform"
    })
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
