module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
}

module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam.eks_cluster_role_arn
  node_role_arn             = module.iam.eks_node_role_arn
  bastion_role_arn          = module.iam.bastion_role_arn
  private_subnet_ids        = module.vpc.private_subnet_ids
  system_node_instance_type = var.system_node_instance_type

  depends_on = [
    module.vpc,
    module.iam
  ]
}

module "bastion" {
  source = "./modules/bastion"

  cluster_name             = var.cluster_name
  vpc_id                   = module.vpc.vpc_id
  public_subnet_id         = module.vpc.public_subnet_ids[0]
  key_name                 = var.key_name
  my_ip_cidr               = var.my_ip_cidr
  instance_type            = var.bastion_instance_type
  bastion_instance_profile = module.iam.bastion_instance_profile_name
  eks_cluster_sg_id        = module.eks.cluster_security_group_id

  depends_on = [
    module.eks
  ]
}

module "karpenter" {
  source = "./modules/karpenter"

  cluster_name           = var.cluster_name
  account_id             = module.iam.account_id
  eks_cluster_arn        = module.eks.cluster_arn
  eks_oidc_issuer        = module.eks.oidc_issuer
  eks_node_role_arn      = module.iam.eks_node_role_arn
  cluster_security_group = module.eks.cluster_security_group_id

  depends_on = [
    module.eks
  ]
}