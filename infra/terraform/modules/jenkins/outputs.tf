output "jenkins_controller_public_ip" {
  description = "Jenkins controller public IP"
  value       = aws_instance.controller.public_ip
}

output "jenkins_controller_private_ip" {
  description = "Jenkins controller private IP"
  value       = aws_instance.controller.private_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.controller.public_ip}:8080"
}

output "jenkins_agent_private_ips" {
  description = "Jenkins agent private IPs"
  value       = aws_instance.agents[*].private_ip
}

output "jenkins_agent_instance_ids" {
  description = "Jenkins agent instance IDs"
  value       = aws_instance.agents[*].id
}

output "jenkins_controller_security_group_id" {
  description = "Jenkins controller security group ID"
  value       = aws_security_group.controller.id
}

output "jenkins_agent_security_group_id" {
  description = "Jenkins agent security group ID"
  value       = aws_security_group.agent.id
}
