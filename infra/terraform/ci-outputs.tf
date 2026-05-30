output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "ecr_repository_names" {
  description = "ECR repository names"
  value       = module.ecr.repository_names
}

output "jenkins_url" {
  description = "Jenkins controller URL"
  value       = module.jenkins.jenkins_url
}

output "jenkins_controller_public_ip" {
  description = "Jenkins controller public IP"
  value       = module.jenkins.jenkins_controller_public_ip
}

output "jenkins_controller_private_ip" {
  description = "Jenkins controller private IP"
  value       = module.jenkins.jenkins_controller_private_ip
}

output "jenkins_agent_private_ips" {
  description = "Jenkins agent private IPs"
  value       = module.jenkins.jenkins_agent_private_ips
}

output "jenkins_agent_instance_ids" {
  description = "Jenkins agent EC2 instance IDs"
  value       = module.jenkins.jenkins_agent_instance_ids
}
