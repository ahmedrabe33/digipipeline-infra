terraform {
  backend "s3" {
    bucket         = "devops-ha-eks-tfstate-429104603739"
    key            = "eks-ha-karpenter/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-ha-eks-tf-locks"
    encrypt        = true

    profile = "default"
  }
}