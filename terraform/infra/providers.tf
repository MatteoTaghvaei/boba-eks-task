terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = {
      Environment = var.environment
      Provisioner = "terraform"
      Project     = var.project_name
      Creator     = var.creator
      Application = var.app_name
      GitRepo     = var.github_repository
    }
  }
}