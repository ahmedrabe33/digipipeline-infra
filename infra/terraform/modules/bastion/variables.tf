variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Bastion"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR for SSH access"
  type        = string
}

variable "instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
}

variable "bastion_instance_profile" {
  description = "IAM instance profile name for Bastion"
  type        = string
}

variable "eks_cluster_sg_id" {
  description = "EKS cluster security group ID"
  type        = string
}