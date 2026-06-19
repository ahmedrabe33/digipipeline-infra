variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ecr_repository_names" {
  description = "ECR repositories for application images"
  type        = list(string)
  default     = ["your-app-image-repo"]
}

variable "jenkins_controller_instance_type" {
  description = "Jenkins controller EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_agent_instance_type" {
  description = "Jenkins agent EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_agent_count" {
  description = "Number of Jenkins agents"
  type        = number
  default     = 2
}

variable "jenkins_aws_region" {
  description = "AWS region for Jenkins CI infrastructure"
  type        = string
  default     = "us-west-2"
}

variable "jenkins_vpc_cidr" {
  description = "VPC CIDR for Jenkins CI region"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/devops-ha-eks-bastion-key.pem.pub"
}
