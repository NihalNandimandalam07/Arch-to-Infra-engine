terraform {
  # 1.10+ is required for native S3 state locking (use_lockfile), used by every stack in this repo.
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.74"
    }
  }
}
