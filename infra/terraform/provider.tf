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
  region  = var.aws_region
  profile = "default"
}
provider "aws" {
  alias   = "ci"
  region  = var.jenkins_aws_region
  profile = "default"
}
