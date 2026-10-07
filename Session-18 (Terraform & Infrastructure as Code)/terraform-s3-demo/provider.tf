terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Every resource this provider creates gets these tags automatically
  default_tags {
    tags = {
      Project   = var.project_name
      Owner     = var.owner
      ManagedBy = "terraform"
    }
  }
}
