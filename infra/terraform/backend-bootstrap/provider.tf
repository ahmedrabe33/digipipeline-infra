terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../credentials"]
  shared_config_files      = ["../config"]
  profile                  = "rabie"
}