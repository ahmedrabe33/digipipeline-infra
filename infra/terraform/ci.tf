module "ecr" {
  source = "./modules/ecr"

  environment      = var.environment
  repository_names = var.ecr_repository_names
}

module "ci_vpc" {
  source = "./modules/ci-vpc"

  providers = {
    aws = aws.ci
  }

  environment = var.environment
  vpc_cidr    = var.jenkins_vpc_cidr
}

module "jenkins" {
  source = "./modules/jenkins"

  providers = {
    aws = aws.ci
  }

  environment               = var.environment
  vpc_id                    = module.ci_vpc.vpc_id
  public_subnet_id          = module.ci_vpc.public_subnet_ids[0]
  private_subnet_ids        = module.ci_vpc.public_subnet_ids
  key_name                  = var.key_name
  public_key_path           = var.public_key_path
  my_ip_cidr                = var.my_ip_cidr
  controller_instance_type  = var.jenkins_controller_instance_type
  agent_instance_type       = var.jenkins_agent_instance_type
  agent_count               = var.jenkins_agent_count
  agent_associate_public_ip = true

  depends_on = [
    module.ci_vpc
  ]
}
