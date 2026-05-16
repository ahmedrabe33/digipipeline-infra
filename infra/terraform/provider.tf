terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["credentials"]
  shared_config_files      = ["config"]
  profile                  = "rabie"
}