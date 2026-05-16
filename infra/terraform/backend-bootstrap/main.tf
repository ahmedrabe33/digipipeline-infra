data "aws_caller_identity" "current" {}

locals {
  project_name = "devops-ha-eks"
  aws_region   = "us-east-1"

  bucket_name = "devops-ha-eks-tfstate-${data.aws_caller_identity.current.account_id}"
  table_name  = "devops-ha-eks-tf-locks"
}

# --------------------------------------------------
# S3 Bucket for Terraform Remote State
# --------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = "production"
    Project     = local.project_name
  }
}

# Enable versioning to protect old state versions
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------------------
# DynamoDB Table for Terraform State Locking
# --------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = local.table_name
    Environment = "production"
    Project     = local.project_name
  }
}