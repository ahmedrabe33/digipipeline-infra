variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS cluster ARN"
  type        = string
}

variable "eks_oidc_issuer" {
  description = "EKS OIDC issuer URL"
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS node IAM role ARN used by Karpenter-created nodes"
  type        = string
}

variable "cluster_security_group" {
  description = "EKS cluster security group ID"
  type        = string
}