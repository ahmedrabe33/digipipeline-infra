variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  type        = string
}

variable "node_role_arn" {
  description = "EKS worker node IAM role ARN"
  type        = string
}

variable "bastion_role_arn" {
  description = "Bastion IAM role ARN for EKS access entry"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS cluster and nodes"
  type        = list(string)
}

variable "system_node_instance_type" {
  description = "Instance type for managed system node group"
  type        = string
}