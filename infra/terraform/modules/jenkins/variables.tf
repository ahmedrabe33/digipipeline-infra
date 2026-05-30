variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Jenkins controller"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Jenkins agents"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR for SSH and Jenkins access"
  type        = string
}

variable "controller_instance_type" {
  description = "Jenkins controller instance type"
  type        = string
  default     = "t3.medium"
}

variable "agent_instance_type" {
  description = "Jenkins agent instance type"
  type        = string
  default     = "t3.medium"
}

variable "agent_count" {
  description = "Number of Jenkins agents"
  type        = number
  default     = 2
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "agent_associate_public_ip" {
  description = "Whether Jenkins agents should have public IPs"
  type        = bool
  default     = false
}
