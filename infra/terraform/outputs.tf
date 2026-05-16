output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  value = module.bastion.bastion_private_ip
}

output "ssh_to_bastion" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.bastion.bastion_public_ip}"
}

output "bastion_role_arn" {
  value = module.iam.bastion_role_arn
}

output "eks_node_role_name" {
  value = module.iam.eks_node_role_name
}

output "eks_node_role_arn" {
  value = module.iam.eks_node_role_arn
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.karpenter_controller_role_arn
}

output "karpenter_node_role_name" {
  value = module.iam.eks_node_role_name
}