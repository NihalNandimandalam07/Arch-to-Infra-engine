terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.74"
    }
  }

  # Settings come from backend.hcl (see backend.hcl.example and README.md).
  backend "s3" {}
}
