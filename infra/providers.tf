provider "aws" {
  region              = var.region
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.tags, {
      Project   = "arch-to-infra-engine"
      Component = "engine"
      ManagedBy = "terraform"
    })
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
