variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-ha-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "Existing EC2 key pair name for Bastion SSH"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR for SSH access to Bastion, example: 197.x.x.x/32"
  type        = string
}

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "system_node_instance_type" {
  description = "Managed system node group instance type"
  type        = string
  default     = "t3.medium"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.35"
}