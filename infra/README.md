# DigiPipeline Terraform Infrastructure

> Terraform Infrastructure as Code for a fully automated multi-region DevOps platform on AWS.

---

## Overview

This directory contains the Terraform code responsible for provisioning the AWS infrastructure for the **DigiPipeline DevOps Platform**.

Terraform builds the cloud infrastructure, while Ansible configures the platform tools on top of it.

The main goal of this Terraform project is to make the infrastructure:

* Automated
* Reproducible
* Modular
* Easy to rebuild
* Easy to understand
* Ready to be configured by Ansible

The infrastructure is designed as a production-style DevOps environment using two AWS regions.

---

## What Terraform Builds

Terraform provisions the core AWS infrastructure required for the platform.

It creates:

* Multi-region AWS infrastructure
* VPC networking
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Bastion host
* Private Amazon EKS cluster
* EKS worker nodes
* IAM roles and policies
* Amazon ECR repositories
* Jenkins controller EC2 instance
* Jenkins agent EC2 instances
* Jenkins security groups
* Karpenter AWS infrastructure
* EKS add-ons
* Terraform remote backend integration

Terraform does not install tools like Jenkins, Argo CD, Grafana, or SonarQube directly.
Terraform creates the infrastructure, and Ansible configures the software layer.

---

## Architecture Summary

DigiPipeline uses two AWS regions.

```text
us-east-1
```

Main platform region.

This region contains:

* VPC
* Public subnets
* Private subnets
* Bastion host
* NAT Gateway
* Internet Gateway
* Private Amazon EKS cluster
* EKS worker nodes
* Karpenter infrastructure
* Amazon ECR
* Amazon EBS support
* IAM roles and policies

```text
us-west-2
```

CI region.

This region contains:

* Jenkins controller EC2 instance
* Jenkins agent EC2 instances
* Jenkins security groups
* IAM permissions for CI/CD and ECR access

Jenkins runs in `us-west-2`, builds Docker images, and pushes them cross-region to Amazon ECR in `us-east-1`.

---

## Multi-Region Architecture Diagram

![DigiPipeline Multi-Region Architecture](../../images/multi-region-architecture.png)

---

## Architecture Explanation

The infrastructure is split into two AWS regions.

### `us-east-1` — Main Platform Region

This is the main Kubernetes platform region.

Terraform provisions the VPC, public subnets, private subnets, Bastion host, NAT Gateway, private EKS cluster, worker nodes, Amazon ECR, IAM roles, and Karpenter infrastructure.

The EKS cluster is private, so it is not accessed directly from the public internet.
Access is handled securely through the Bastion host.

The application is exposed later through an AWS Application Load Balancer created by the AWS Load Balancer Controller after Ansible installs the Kubernetes platform tools.

### `us-west-2` — CI Region

This region contains Jenkins infrastructure.

Terraform provisions:

* Jenkins controller EC2 instance
* Jenkins agent EC2 instances
* Jenkins security groups
* IAM permissions needed for CI/CD

Jenkins agents build Docker images, run scans, push images to Amazon ECR in `us-east-1`, and update the GitOps repository.

---

## Full Platform Automation

This Terraform code is part of a larger automated workflow.

The recommended way to build the whole platform is through Ansible:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This command runs the full automation flow:

```text
Run Terraform
      |
      v
Create AWS infrastructure
      |
      v
Read Terraform outputs
      |
      v
Update Ansible inventory
      |
      v
Configure Bastion access
      |
      v
Configure EKS access
      |
      v
Install platform tools
      |
      v
Install Jenkins
      |
      v
Configure Jenkins agents automatically
      |
      v
Configure SonarQube token inside Jenkins automatically
      |
      v
Install monitoring and DevSecOps tools
      |
      v
Print URLs, usernames, and passwords
```

The project is designed so that the user does not need to manually configure everything after every rebuild.

---

## Terraform and Ansible Responsibilities

| Task                                 | Terraform | Ansible |
| ------------------------------------ | --------- | ------- |
| Create VPC                           | Yes       | No      |
| Create public subnets                | Yes       | No      |
| Create private subnets               | Yes       | No      |
| Create NAT Gateway                   | Yes       | No      |
| Create Internet Gateway              | Yes       | No      |
| Create Bastion EC2                   | Yes       | No      |
| Create private EKS cluster           | Yes       | No      |
| Create EKS worker nodes              | Yes       | No      |
| Create ECR repositories              | Yes       | No      |
| Create Jenkins EC2 instances         | Yes       | No      |
| Create IAM roles and policies        | Yes       | No      |
| Install Argo CD                      | No        | Yes     |
| Install AWS Load Balancer Controller | No        | Yes     |
| Install Karpenter with Helm          | No        | Yes     |
| Install Prometheus and Grafana       | No        | Yes     |
| Install Jenkins software             | No        | Yes     |
| Configure Jenkins agents             | No        | Yes     |
| Store SonarQube token inside Jenkins | No        | Yes     |
| Install SonarQube                    | No        | Yes     |
| Install Trivy                        | No        | Yes     |
| Create Kubernetes secrets            | No        | Yes     |
| Bootstrap GitOps application         | No        | Yes     |

Terraform builds the infrastructure.
Ansible configures and operates the platform.

---

## Directory Structure

```text
infra/terraform/
|
|-- backend.tf
|-- main.tf
|-- provider.tf
|-- variable.tf
|-- outputs.tf
|-- terraform.tfvars.example
|
|-- modules/
|   |
|   |-- vpc/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- iam/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- eks/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- bastion/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- karpenter/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- ecr/
|   |   |-- main.tf
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |
|   |-- jenkins/
|       |-- main.tf
|       |-- variables.tf
|       |-- outputs.tf
```

---

## Main Terraform Files

| File                       | Purpose                                                 |
| -------------------------- | ------------------------------------------------------- |
| `backend.tf`               | Configures remote Terraform state using S3 and DynamoDB |
| `provider.tf`              | Configures AWS providers and regions                    |
| `main.tf`                  | Calls the Terraform modules                             |
| `variable.tf`              | Defines input variables                                 |
| `outputs.tf`               | Exports values used by Ansible                          |
| `terraform.tfvars.example` | Example variables file                                  |

---

## Terraform Modules

### VPC Module

The VPC module creates the networking layer in `us-east-1`.

It provisions:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Route table associations

Public subnets are used for:

* Bastion host
* NAT Gateway
* Internet-facing Application Load Balancer

Private subnets are used for:

* EKS worker nodes
* Application workloads
* Kubernetes platform services

---

### IAM Module

The IAM module creates IAM roles and policies required by the platform.

It supports:

* EKS cluster IAM role
* EKS node group IAM role
* Bastion permissions
* Jenkins permissions
* ECR access
* Karpenter permissions
* AWS service integrations

IAM is used to allow platform components to interact securely with AWS services.

---

### EKS Module

The EKS module provisions the private Amazon EKS cluster.

It creates:

* EKS cluster
* Private cluster endpoint
* Managed node group
* EKS cluster security group
* EKS node security group
* Required IAM role attachments
* EKS add-ons

The EKS cluster is private and is accessed through the Bastion host.

---

### Bastion Module

The Bastion module creates the public management entry point for the private EKS cluster.

It provisions:

* Bastion EC2 instance
* Public IP
* Security group
* SSH access configuration
* Key pair usage

The Bastion host is used by Ansible for:

* `kubectl`
* Helm
* Cluster verification
* Argo CD bootstrap
* Access tunnels
* Troubleshooting

---

### ECR Module

The ECR module creates Amazon ECR repositories in `us-east-1`.

Amazon ECR stores the Docker images built by Jenkins.

The flow is:

```text
Jenkins Agent
      |
      v
Build Docker Image
      |
      v
Push Image to Amazon ECR
      |
      v
Kubernetes pulls image from ECR
```

---

### Jenkins Module

The Jenkins module creates the CI infrastructure in `us-west-2`.

It provisions:

* Jenkins controller EC2 instance
* Jenkins agent EC2 instances
* Jenkins security groups
* Jenkins-related IAM permissions
* Networking configuration for Jenkins instances

Terraform only creates the Jenkins machines.
Ansible installs Jenkins, prepares agents, registers agents, installs plugins, and configures credentials.

---

### Karpenter Module

The Karpenter module prepares the AWS-side infrastructure needed for Kubernetes autoscaling.

It supports:

* Karpenter IAM role
* Karpenter node role
* Instance profile
* Required policies
* EKS integration

Karpenter itself is installed later by Ansible using Helm.

---

## Remote Backend

Terraform uses a remote backend for state management.

Backend services:

| Service   | Purpose                |
| --------- | ---------------------- |
| Amazon S3 | Stores Terraform state |
| DynamoDB  | Provides state locking |

Example backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "digipipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-lock-table"
    encrypt        = true
    profile        = "default"
  }
}
```

Remote state is important because it allows infrastructure state to be reused across machines and prevents losing Terraform state.

Do not delete the S3 backend bucket or DynamoDB lock table unless you intentionally want to reset the infrastructure state.

---

## Variables

Terraform variables are defined in:

```text
variable.tf
```

Example variable values are provided in:

```text
terraform.tfvars.example
```

Create your own variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then update the values based on your AWS account and environment.

Do not commit real sensitive values inside:

```text
terraform.tfvars
```

---

## Common Variables

| Variable                           | Description                              |
| ---------------------------------- | ---------------------------------------- |
| `aws_region`                       | Main AWS region for the EKS platform     |
| `ci_region`                        | AWS region for Jenkins infrastructure    |
| `project_name`                     | Project name used for resource naming    |
| `environment`                      | Environment name such as `dev`           |
| `vpc_cidr`                         | CIDR block for the VPC                   |
| `public_subnet_cidrs`              | CIDR blocks for public subnets           |
| `private_subnet_cidrs`             | CIDR blocks for private subnets          |
| `cluster_name`                     | EKS cluster name                         |
| `node_instance_types`              | EC2 instance types for EKS nodes         |
| `bastion_instance_type`            | EC2 instance type for Bastion            |
| `jenkins_controller_instance_type` | EC2 instance type for Jenkins controller |
| `jenkins_agent_instance_type`      | EC2 instance type for Jenkins agents     |
| `bastion_key_name`                 | AWS key pair name for Bastion            |
| `jenkins_key_name`                 | AWS key pair name for Jenkins            |

---

## Outputs

Terraform exports important infrastructure values through:

```text
outputs.tf
```

These outputs are used by Ansible automatically.

Typical outputs include:

* VPC ID
* Public subnet IDs
* Private subnet IDs
* Bastion public IP
* EKS cluster name
* EKS cluster endpoint
* EKS node security group ID
* Jenkins controller public IP
* Jenkins agent private IPs
* ECR repository URLs
* Karpenter IAM information

Ansible reads these outputs after Terraform finishes and updates inventory and variables automatically.

---

## Recommended Usage

The recommended way to build the infrastructure is through the Ansible master playbook.

From the Ansible directory:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible
```

Run the full build:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This runs Terraform and continues with the full platform setup.

---

## Manual Terraform Usage

You can also run Terraform manually if needed.

Go to the Terraform directory:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/infra/terraform
```

Initialize Terraform:

```bash
terraform init
```

Format Terraform files:

```bash
terraform fmt -recursive
```

Validate Terraform configuration:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

Show outputs:

```bash
terraform output
```

Show outputs as JSON:

```bash
terraform output -json
```

---

## Full Infrastructure and Platform Build

To build everything from scratch:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This command builds the infrastructure and configures the platform.

After that, open dashboards and show access information:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

The access playbooks show:

* Application URL
* Argo CD URL
* Argo CD password
* Jenkins URL
* Jenkins password
* Grafana URL
* Grafana credentials
* SonarQube URL
* SonarQube credentials
* ECR information

---

## Infrastructure Components Created in `us-east-1`

| Component           | Purpose                               |
| ------------------- | ------------------------------------- |
| VPC                 | Main isolated network                 |
| Public subnets      | Bastion, NAT Gateway, and public ALB  |
| Private subnets     | EKS worker nodes and workloads        |
| Internet Gateway    | Public internet access                |
| NAT Gateway         | Outbound internet for private subnets |
| Bastion host        | Secure access to private EKS          |
| EKS cluster         | Kubernetes control plane              |
| EKS node group      | Worker nodes                          |
| ECR repositories    | Container image registry              |
| Security groups     | Network access control                |
| IAM roles           | AWS permissions                       |
| Karpenter resources | Autoscaling support                   |

---

## Infrastructure Components Created in `us-west-2`

| Component                   | Purpose                |
| --------------------------- | ---------------------- |
| Jenkins controller EC2      | CI/CD controller       |
| Jenkins agent EC2 instances | Build workers          |
| Jenkins security groups     | Jenkins network access |
| Jenkins IAM permissions     | ECR and CI access      |

---

## Private EKS Design

The EKS cluster is private.

This means:

* The Kubernetes API is not publicly exposed.
* Direct public access to the cluster is avoided.
* Access is controlled through the Bastion host.
* Ansible connects through the Bastion host.
* Local dashboard access is opened through tunnels.

This design is closer to a production environment than a public Kubernetes cluster.

---

## Jenkins and ECR Cross-Region Flow

Jenkins runs in:

```text
us-west-2
```

Amazon ECR runs in:

```text
us-east-1
```

The CI/CD flow is:

```text
Jenkins Agent
      |
      v
Build Docker Image
      |
      v
Authenticate to Amazon ECR in us-east-1
      |
      v
Push Docker Image to Amazon ECR
      |
      v
Update GitOps Repository
      |
      v
Argo CD Deploys to EKS
```

Terraform creates the infrastructure required for this flow.
Ansible configures Jenkins and its agents automatically after Terraform finishes.

---

## Automation Notes

This project is designed so that most manual configuration is avoided.

Ansible automatically handles:

* Running Terraform
* Reading Terraform outputs
* Updating inventory
* Configuring Bastion access
* Configuring EKS access
* Installing Jenkins
* Preparing Jenkins agents
* Registering Jenkins agents
* Installing Jenkins plugins
* Configuring Jenkins ECR access
* Installing SonarQube
* Creating or retrieving SonarQube token
* Storing SonarQube token inside Jenkins credentials
* Installing Trivy
* Installing monitoring tools
* Creating Kubernetes secrets
* Bootstrapping Argo CD application

The result is a platform that can be rebuilt and operated easily.

---

## Tags

Terraform resources should use consistent tags.

Example:

```hcl
tags = {
  Project     = "DigiPipeline"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

Tags help identify and manage AWS resources.

---

## State Management

Terraform state tracks created infrastructure.

Important notes:

* Do not edit Terraform state manually.
* Do not delete remote state unless you know what you are doing.
* Do not commit local state files.
* Always use the configured backend.
* Use DynamoDB locking to avoid concurrent Terraform operations.

---

## Destroy Infrastructure

To destroy Terraform-managed infrastructure:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/infra/terraform

terraform init
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

---

## Clean ECR Before Destroy

If ECR repositories contain images, Terraform may fail to destroy them.

Clean ECR repositories before destroying:

```bash
for REPO in $(aws ecr describe-repositories \
  --region us-east-1 \
  --query "repositories[].repositoryName" \
  --output text); do

  echo "Cleaning ECR repo: $REPO"

  IMAGES=$(aws ecr list-images \
    --region us-east-1 \
    --repository-name "$REPO" \
    --query 'imageIds[*]' \
    --output json)

  if [ "$IMAGES" != "[]" ]; then
    aws ecr batch-delete-image \
      --region us-east-1 \
      --repository-name "$REPO" \
      --image-ids "$IMAGES" || true
  fi
done
```

Then run destroy again.

---

## Force Unlock Terraform State

If Terraform is interrupted, the state may remain locked.

Terraform will show a lock ID.

Unlock carefully:

```bash
terraform force-unlock -force <LOCK_ID>
```

Then retry:

```bash
terraform plan
terraform apply
```

---

## Security Notes

Do not commit:

* `terraform.tfvars`
* Private keys
* AWS credentials
* Terraform state files
* `.terraform/`
* kubeconfig files
* Tokens
* Passwords
* Plan files containing sensitive values

Recommended `.gitignore` entries:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
*.tfplan
*.pem
*.key
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

---

## Troubleshooting

### Terraform Init Fails

Check AWS identity:

```bash
aws sts get-caller-identity
```

Check that the backend S3 bucket and DynamoDB lock table exist.

Then retry:

```bash
terraform init -reconfigure
```

---

### Terraform Plan Fails

Run:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

Check variable values inside:

```text
terraform.tfvars
```

---

### ECR Destroy Fails

If ECR repositories still contain images, clean images first:

```bash
aws ecr list-images --region us-east-1 --repository-name <repo-name>
```

Then delete images and rerun destroy.

---

### EKS Access Fails After Apply

Terraform creates the cluster, but Ansible configures access.

Run:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/00-rebuild-infra.yml
```

Or run the full master playbook:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

---

### Jenkins Instances Are Created But Jenkins Is Not Ready

Terraform creates Jenkins EC2 instances only.

Jenkins software installation and agent configuration are handled by Ansible.

Run:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/30-install-ci.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
```

---

## Quick Commands

### Full Infrastructure and Platform Build

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

---

### Terraform Only

```bash
cd ~/digipipeline-workspace/digipipeline-infra/infra/terraform

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

---

### Show Terraform Outputs

```bash
terraform output
terraform output -json
```

---

### Destroy Terraform Infrastructure

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

---

## What This Terraform Project Demonstrates

This Terraform project demonstrates:

* AWS Infrastructure as Code
* Multi-region infrastructure design
* Private Amazon EKS architecture
* Bastion-based secure access
* VPC networking
* Public and private subnet design
* NAT Gateway usage
* IAM role automation
* Amazon ECR provisioning
* Jenkins infrastructure provisioning
* Karpenter infrastructure preparation
* Terraform remote backend
* Terraform modules
* Terraform outputs integration with Ansible
* Automated infrastructure rebuild workflow

---

## Author

**Ahmed Rabie**
DevOps Engineer

GitHub: [ahmedrabe33](https://github.com/ahmedrabe33)

Built as part of the **DigiPipeline DevOps Project**.
