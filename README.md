# DigiPipeline Infrastructure

Production-style DevOps infrastructure platform built with Terraform, Ansible, AWS EKS, Jenkins, Argo CD, Karpenter, Amazon ECR, Prometheus, Grafana, SonarQube, and Trivy.

This repository provisions and configures a complete cloud-native delivery platform on AWS, including networking, private Kubernetes infrastructure, CI/CD infrastructure, GitOps deployment, container registry, persistent storage, monitoring, DevSecOps tooling, and secure access automation.

---

## Project Overview

DigiPipeline is a multi-repository DevOps platform designed to simulate a real-world production environment.

The project is split into three repositories:

| Repository                                                                  | Purpose                                                                        |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [`digipipeline-infra`](https://github.com/ahmedrabe33/digipipeline-infra)   | Infrastructure automation using Terraform and Ansible                          |
| [`digipipeline-gitops`](https://github.com/ahmedrabe33/digipipeline-gitops) | Kubernetes manifests, Kustomize overlays, and Argo CD deployment configuration |
| [`digipipeline-app`](https://github.com/ahmedrabe33/digipipeline-app)       | Application source code, Dockerfiles, and CI build context                     |

This separation follows a real production pattern:

```text
Application code        -> digipipeline-app
Kubernetes desired state -> digipipeline-gitops
Infrastructure platform  -> digipipeline-infra
```

The goal of the project is to automate the full DevOps platform lifecycle:

```text
Build Infrastructure
  -> Configure Secure Access
  -> Install Kubernetes Platform Tools
  -> Install CI Infrastructure
  -> Configure DevSecOps Tools
  -> Build and Push Container Images
  -> Update GitOps Manifests
  -> Deploy Application to EKS
  -> Expose Application and Dashboards
```

---

## High-Level Architecture

DigiPipeline uses a multi-region AWS architecture.

```text
                              Developer
                                  |
                                  v
                           GitHub Repositories
                                  |
                -------------------------------------
                |                 |                 |
                v                 v                 v
        digipipeline-app   digipipeline-gitops   digipipeline-infra
                |                 |                 |
                |                 |                 v
                |                 |        Terraform + Ansible
                |                 |                 |
                |                 |                 v
                |                 |        AWS Infrastructure
                |                 |
                v                 |
        Jenkins CI - us-west-2    |
                |                 |
                v                 |
       Build Docker Images        |
                |                 |
                v                 |
       Push Images to ECR         |
          us-east-1               |
                |                 |
                v                 |
       Update GitOps Manifests ---|
                                  |
                                  v
                         Argo CD - us-east-1
                                  |
                                  v
                         Private EKS Cluster
                                  |
                   --------------------------------
                   |              |               |
                   v              v               v
             Application     Monitoring      Platform Tools
             Workloads       Stack           Argo CD / Karpenter
                   |
                   v
        AWS Load Balancer Controller
                   |
                   v
        Public Application Load Balancer
```

---

## Regional Architecture

DigiPipeline is deployed across two AWS regions.

### Primary Platform Region

```text
us-east-1
```

This region hosts the main Kubernetes and application platform.

Main resources in `us-east-1`:

```text
VPC
Public subnets
Private subnets
Internet Gateway
NAT Gateways
Route tables
Private EKS cluster
Managed node group
Karpenter node provisioning
Amazon ECR repositories
Bastion host
Argo CD
AWS Load Balancer Controller
Prometheus
Grafana
Application workloads
Persistent volumes using Amazon EBS
```

### CI Region

```text
us-west-2
```

This region hosts the external CI infrastructure.

Main resources in `us-west-2`:

```text
Jenkins controller EC2 instance
Jenkins agent EC2 instances
Jenkins security groups
CI-related IAM permissions
Docker build environment
```

Jenkins runs in `us-west-2`, builds Docker images, and pushes them cross-region to Amazon ECR in `us-east-1`.

Argo CD runs inside the EKS cluster in `us-east-1` and deploys Kubernetes manifests from the GitOps repository.

---

## Network Architecture

The primary AWS platform is built inside a dedicated VPC in `us-east-1`.

```text
VPC - us-east-1
|
|-- Public Subnets
|   |
|   |-- Bastion Host
|   |-- NAT Gateways
|   |-- Internet-facing Application Load Balancer
|
|-- Private Subnets
|   |
|   |-- EKS Worker Nodes
|   |-- Application Pods
|   |-- Argo CD
|   |-- Prometheus
|   |-- Grafana
|   |-- Karpenter-provisioned nodes
```

The EKS cluster is private. It is not accessed directly from the public internet.

The Bastion host is used as the controlled access point for:

```text
kubectl access
Helm operations
EKS troubleshooting
Argo CD bootstrap
Monitoring verification
Local SSH tunnels
Access automation
```

---

## CI/CD and GitOps Flow

DigiPipeline separates CI and CD responsibilities.

### CI Responsibility

Jenkins is responsible for CI tasks.

Jenkins runs in `us-west-2` and performs:

```text
Checkout source code from digipipeline-app
Install dependencies
Run tests
Run SonarQube analysis
Build Docker images
Scan images using Trivy
Push Docker images to Amazon ECR in us-east-1
Update image tags in digipipeline-gitops
```

### CD Responsibility

Argo CD is responsible for continuous delivery.

Argo CD runs inside the private EKS cluster in `us-east-1` and performs:

```text
Watch digipipeline-gitops
Detect Kubernetes manifest changes
Sync application resources to EKS
Maintain desired state
Show sync and health status
```

### Full Delivery Flow

```text
Developer pushes code
        |
        v
digipipeline-app
        |
        v
Jenkins pipeline starts
        |
        v
Build and test application
        |
        v
Run SonarQube and Trivy checks
        |
        v
Build Docker images
        |
        v
Push images to Amazon ECR
        |
        v
Update image tags in digipipeline-gitops
        |
        v
Argo CD detects GitOps change
        |
        v
Argo CD syncs application to EKS
        |
        v
AWS Load Balancer Controller exposes application through ALB
```

---

## Main Components

### Terraform

Terraform is used to provision AWS infrastructure.

Terraform provisions:

```text
VPC
Public and private subnets
Internet Gateway
NAT Gateways
Route tables
EKS cluster
Managed node group
IAM roles and policies
Bastion host
Jenkins controller
Jenkins agents
Amazon ECR repositories
Karpenter IAM resources
EKS add-ons
```

Detailed Terraform documentation should be maintained in:

```text
infra/terraform/README.md
```

---

### Ansible

Ansible is used to automate infrastructure orchestration and platform configuration.

Ansible automates:

```text
SSH key pair preparation
Terraform execution
Terraform output parsing
Dynamic inventory updates
Group variables updates
Bastion configuration
EKS kubeconfig setup
Cluster verification
Argo CD installation
AWS Load Balancer Controller installation
Karpenter installation
Prometheus and Grafana installation
Default StorageClass configuration
GitOps application bootstrap
Jenkins controller installation
Jenkins agent preparation
Jenkins GitHub plugin setup
Jenkins agent configuration
Jenkins to ECR IAM configuration
SonarQube installation
Trivy installation
SonarQube and Jenkins integration
Local access tunnels
Access information output
```

Detailed Ansible documentation should be maintained in:

```text
ansible/README.md
```

---

### EKS Platform

The Kubernetes platform includes:

```text
Private Amazon EKS cluster
Managed system node group
Karpenter for dynamic node provisioning
Argo CD for GitOps delivery
AWS Load Balancer Controller for ALB provisioning
Prometheus for metrics collection
Grafana for dashboards
Amazon EBS persistent storage support
Application workloads deployed through GitOps
```

---

### Amazon ECR

Amazon ECR is used as the container image registry.

ECR is created in:

```text
us-east-1
```

Jenkins in `us-west-2` builds Docker images and pushes them to ECR in `us-east-1`.

Argo CD deploys Kubernetes manifests that reference those ECR images.

---

### Bastion Host

The Bastion host is deployed in the public subnet of the primary VPC in `us-east-1`.

It is used as the secure management entry point for the private EKS cluster.

Main Bastion responsibilities:

```text
Run kubectl against the private EKS cluster
Run Helm commands
Verify cluster resources
Create local tunnels to dashboards
Bootstrap Argo CD applications
Troubleshoot platform components
```

All project operations are intended to be triggered from the local control machine using Ansible, not by manually SSHing into the Bastion host.

---

### Jenkins CI

Jenkins is deployed in `us-west-2`.

The CI layer contains:

```text
Jenkins controller
Jenkins build agents
Docker build environment
GitHub integration
ECR push permissions
SonarQube integration
Trivy image scanning
```

Jenkins is outside the EKS cluster to simulate a real external CI system that deploys into a cloud Kubernetes platform.

---

### Argo CD GitOps

Argo CD is deployed inside the private EKS cluster.

It watches:

```text
digipipeline-gitops
```

Argo CD is responsible for applying and maintaining Kubernetes desired state.

The GitOps repository contains:

```text
Kubernetes manifests
Kustomize overlays
Environment-specific configuration
Image tags updated by Jenkins
Application deployment configuration
```

---

### Persistent Storage

DigiPipeline supports persistent Kubernetes workloads using Amazon EBS volumes.

PostgreSQL runs as a StatefulSet and uses a PersistentVolumeClaim.

The storage design uses:

```text
AWS EBS CSI Driver
Default Kubernetes StorageClass
PostgreSQL PVC
```

The StorageClass configuration is automated using Ansible:

```bash
ansible-playbook playbooks/04-configure-default-storageclass.yml
```

This helps prevent PostgreSQL PVCs from staying in `Pending` state after a fresh rebuild.

---

### Monitoring

Monitoring is installed inside the EKS cluster.

The monitoring stack includes:

```text
Prometheus
Grafana
Kubernetes metrics collection
Dashboards for platform visibility
```

Access to monitoring is automated through local tunnels.

---

### DevSecOps

The project includes DevSecOps automation using:

```text
SonarQube
Trivy
Jenkins integration
ECR IAM configuration
Jenkins GitHub plugin setup
Jenkins agent configuration
```

The main DevSecOps automation playbook is:

```bash
ansible-playbook playbooks/31-install-devsecops.yml
```

Optional SonarQube integration with Jenkins:

```bash
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

---

## Repository Structure

```text
digipipeline-infra/
|
|-- ansible/
|   |
|   |-- ansible.cfg
|   |
|   |-- inventories/
|   |   |-- dev/
|   |   |   |-- hosts.ini
|   |
|   |-- group_vars/
|   |
|   |-- playbooks/
|   |   |
|   |   |-- 00-ensure-keypairs.yml
|   |   |-- 00-rebuild-infra.yml
|   |   |-- 00-verify-cluster.yml
|   |   |-- 01-install-argocd.yml
|   |   |-- 02-argocd-password.yml
|   |   |-- 03-install-aws-load-balancer-controller.yml
|   |   |-- 04-configure-default-storageclass.yml
|   |   |-- 06-install-karpenter.yml
|   |   |-- 09-install-monitoring.yml
|   |   |-- 10-install-platform.yml
|   |   |-- 11-bootstrap-gitops-app.yml
|   |   |-- 12-show-access-info.yml
|   |   |-- 20-install-jenkins-controller.yml
|   |   |-- 21-prepare-jenkins-agents.yml
|   |   |-- 22-show-ci-info.yml
|   |   |-- 24-install-sonarqube.yml
|   |   |-- 25-install-trivy.yml
|   |   |-- 26-open-sonarqube-access.yml
|   |   |-- 27-setup-sonarqube-for-jenkins.yml
|   |   |-- 27-verify-devsecops.yml
|   |   |-- 29-install-jenkins-github-plugins.yml
|   |   |-- 30-install-ci.yml
|   |   |-- 31-install-devsecops.yml
|   |   |-- 32-configure-jenkins-agents.yml
|   |   |-- 32-configure-jenkins-ecr-iam.yml
|   |   |-- open-all-access.yml
|   |   |-- 99-run-all-digipipeline.yml
|   |
|   |-- README.md
|
|-- infra/
|   |
|   |-- terraform/
|   |   |
|   |   |-- backend.tf
|   |   |-- main.tf
|   |   |-- provider.tf
|   |   |-- variable.tf
|   |   |-- outputs.tf
|   |   |-- terraform.tfvars.example
|   |   |
|   |   |-- modules/
|   |   |   |-- vpc/
|   |   |   |-- iam/
|   |   |   |-- eks/
|   |   |   |-- bastion/
|   |   |   |-- karpenter/
|   |   |   |-- ecr/
|   |   |   |-- jenkins/
|   |   |
|   |   |-- README.md
|
|-- .gitignore
|-- README.md
```

---

## Prerequisites

Before running the project, install and configure:

```text
AWS CLI
Terraform
Ansible
kubectl
Helm
Git
SSH client
AWS account with required permissions
GitHub repositories for app and GitOps manifests
```

Check AWS identity:

```bash
aws sts get-caller-identity
```

Check required tools:

```bash
terraform version
ansible --version
kubectl version --client
helm version
aws --version
git --version
```

---

## Terraform Backend

Terraform uses a remote backend for state management.

Backend components:

```text
S3 bucket for Terraform state
DynamoDB table for Terraform state locking
```

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "eks-ha-karpenter/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-lock-table"
    encrypt        = true
    profile        = "default"
  }
}
```

Do not delete the backend S3 bucket or DynamoDB lock table unless you intentionally want to remove Terraform state management.

---

## How to Deploy

Run all commands from the local control machine.

```bash
cd digipipeline-infra/ansible
```

---

### 1. Prepare SSH Key Pairs

```bash
ansible-playbook playbooks/00-ensure-keypairs.yml
```

This playbook prepares and validates the required EC2 SSH key pairs.

It handles key material required for:

```text
Bastion access in us-east-1
Jenkins controller and agents in us-west-2
```

---

### 2. Build AWS Infrastructure

```bash
ansible-playbook playbooks/00-rebuild-infra.yml
```

This playbook runs Terraform and prepares Ansible inventory.

It performs:

```text
Terraform init
Terraform fmt
Terraform validate
Terraform apply
Terraform output parsing
Inventory update
Group variables update
Bastion kubeconfig configuration
Initial EKS verification
```

Infrastructure created includes:

```text
VPC
Public and private subnets
Internet Gateway
NAT Gateways
Private EKS cluster
Managed node group
Bastion host
Jenkins controller
Jenkins agents
ECR repositories
IAM roles and policies
Karpenter resources
```

---

### 3. Install Kubernetes Platform

```bash
ansible-playbook playbooks/10-install-platform.yml
```

This playbook installs the core Kubernetes platform tools.

It includes:

```text
Cluster verification
Default StorageClass configuration
Argo CD installation
AWS Load Balancer Controller installation
Karpenter installation
Prometheus and Grafana installation
Final cluster verification
```

---

### 4. Bootstrap GitOps Application

```bash
ansible-playbook playbooks/11-bootstrap-gitops-app.yml
```

This creates the Argo CD application that watches the GitOps repository and deploys the Kubernetes workloads.

---

### 5. Install Jenkins CI

```bash
ansible-playbook playbooks/30-install-ci.yml
```

This installs and prepares:

```text
Jenkins controller
Jenkins agents
CI access information
```

Optional Jenkins automation:

```bash
ansible-playbook playbooks/29-install-jenkins-github-plugins.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-ecr-iam.yml
```

---

### 6. Install DevSecOps Tools

```bash
ansible-playbook playbooks/31-install-devsecops.yml
```

This installs and verifies:

```text
SonarQube
Trivy
DevSecOps validation
SonarQube access
```

Optional SonarQube integration with Jenkins:

```bash
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

---

### 7. Open Local Access Tunnels

```bash
ansible-playbook playbooks/open-all-access.yml
```

This opens local tunnels for:

```text
Argo CD
Jenkins
SonarQube
Grafana
Prometheus
```

Access credentials are printed by the related Ansible playbooks when available.

Do not store real passwords or secrets directly in this README.

---

## Recommended Rebuild Flow

For a clean rebuild, use:

```bash
ansible-playbook playbooks/00-ensure-keypairs.yml
ansible-playbook playbooks/00-rebuild-infra.yml
ansible-playbook playbooks/10-install-platform.yml
ansible-playbook playbooks/11-bootstrap-gitops-app.yml
ansible-playbook playbooks/30-install-ci.yml
ansible-playbook playbooks/29-install-jenkins-github-plugins.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-ecr-iam.yml
ansible-playbook playbooks/31-install-devsecops.yml
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
ansible-playbook playbooks/open-all-access.yml
```

After a fresh rebuild, the application images may need to be rebuilt and pushed again by Jenkins because ECR may be empty.

---

## Useful Commands

### Check EKS nodes

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" get nodes -o wide'
```

### Check all pods

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" get pods -A'
```

### Check Argo CD applications

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd get applications'
```

### Check application namespace

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get all'
```

### Check persistent volume claims

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pvc'
```

### Check StorageClasses

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" get storageclass'
```

### Check monitoring services

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n monitoring get svc'
```

### Show access information

```bash
ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

---

## Destroy Infrastructure

To destroy all Terraform-managed resources:

```bash
cd infra/terraform
terraform init
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

If a Terraform lock remains from a previous interrupted operation, unlock it carefully using the lock ID shown in the Terraform error:

```bash
terraform force-unlock -force <LOCK_ID>
```

If ECR repositories contain images, clean them before destroying the infrastructure:

```bash
for REPO in $(aws ecr describe-repositories \
  --region us-east-1 \
  --query "repositories[?contains(repositoryName, 'digipipeline')].repositoryName" \
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

After destroy, verify Terraform state:

```bash
terraform state list
```

Check AWS resources in both regions:

```bash
for REGION in us-east-1 us-west-2; do
  echo "===== $REGION ====="

  aws eks list-clusters \
    --region $REGION \
    --profile default \
    --output table

  aws ec2 describe-instances \
    --region $REGION \
    --profile default \
    --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
    --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,State:State.Name,Id:InstanceId,PublicIP:PublicIpAddress}" \
    --output table

  aws elbv2 describe-load-balancers \
    --region $REGION \
    --profile default \
    --query "LoadBalancers[].[LoadBalancerName,State.Code,DNSName]" \
    --output table

  aws ec2 describe-vpcs \
    --region $REGION \
    --profile default \
    --filters "Name=tag:Project,Values=digipipeline" \
    --query "Vpcs[].{Name:Tags[?Key=='Name']|[0].Value,VpcId:VpcId,State:State}" \
    --output table
done
```

Do not delete the Terraform backend S3 bucket or DynamoDB lock table unless you intentionally want to remove remote state management.

---

## Troubleshooting

### PostgreSQL PVC stays Pending

Check PVC status:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pvc'
```

Check StorageClass:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" get storageclass'
```

Run StorageClass automation:

```bash
ansible-playbook playbooks/04-configure-default-storageclass.yml
```

If the PVC was created before the StorageClass was configured, delete the old development PVC and let Argo CD recreate it:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev delete pod postgres-0 --ignore-not-found'
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev delete pvc postgres-data-postgres-0'
```

This is safe for the demo development environment, but it deletes PostgreSQL data stored in that PVC.

---

### Argo CD shows OutOfSync or Degraded

Check Argo CD application resources:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development -o jsonpath="{range .status.resources[*]}{.kind}{\"\t\"}{.namespace}{\"\t\"}{.name}{\"\t\"}{.status}{\"\t\"}{.health.status}{\"\n\"}{end}"'
```

Check application pods:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods'
```

Common causes:

```text
Pending PVC
ImagePullBackOff
ErrImageNeverPull
CreateContainerConfigError
Missing Secret
Missing ConfigMap
Wrong image tag
Empty ECR repository after rebuild
```

---

### Terraform state is locked

If a previous Terraform operation was interrupted, Terraform may keep a lock in DynamoDB.

Use the lock ID shown in the error:

```bash
terraform force-unlock -force <LOCK_ID>
```

Then retry the operation:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

---

### Bastion SSH timeout

If Ansible cannot reach the Bastion host, check:

```text
Your current public IP
Security group ingress rules
Bastion instance state
SSH key path
Ansible inventory
```

If the goal is to destroy everything and Bastion is unreachable, use Terraform destroy directly from the local machine.

---

## Security Notes

This project uses temporary public access for learning and demonstration purposes.

Recommended production improvements:

```text
Use private Jenkins access through VPN, SSM, or private networking
Avoid exposing Jenkins directly to the internet
Store secrets in AWS Secrets Manager or External Secrets Operator
Use Jenkins credentials securely
Enable HTTPS using ACM and Route 53
Restrict security groups to trusted IP addresses
Enable CloudWatch logs and Kubernetes audit logging
Add backup and disaster recovery strategy
Use least privilege IAM policies
Use IRSA for Kubernetes service accounts
Use private container registry access controls
Enable image signing and policy enforcement
```

---

## What This Project Demonstrates

This project demonstrates practical DevOps and Cloud Engineering skills:

```text
Infrastructure as Code with Terraform
Configuration automation with Ansible
AWS multi-region infrastructure design
AWS networking and subnet design
Private EKS cluster provisioning
Bastion-based secure cluster access
CI infrastructure with Jenkins
Jenkins controller and agent automation
Cross-region image push to Amazon ECR
GitOps delivery with Argo CD
Kubernetes deployment automation
Persistent storage using EBS and PVCs
Monitoring with Prometheus and Grafana
DevSecOps with SonarQube and Trivy
Karpenter-based node provisioning
Remote state management with S3 and DynamoDB
End-to-end DevOps platform automation
```

---

## Tech Stack

| Category               | Tools                         |
| ---------------------- | ----------------------------- |
| Cloud                  | AWS                           |
| Infrastructure as Code | Terraform                     |
| Automation             | Ansible                       |
| Containers             | Docker                        |
| Orchestration          | Kubernetes / Amazon EKS       |
| CI                     | Jenkins                       |
| GitOps                 | Argo CD                       |
| Registry               | Amazon ECR                    |
| Security Scanning      | Trivy                         |
| Code Quality           | SonarQube                     |
| Monitoring             | Prometheus                    |
| Dashboards             | Grafana                       |
| Scaling                | Karpenter                     |
| Access                 | Bastion Host / SSH Tunnels    |
| State Management       | S3 Backend / DynamoDB Locking |

---

## Project Status

Current project status:

```text
Infrastructure automation: Implemented
EKS provisioning: Implemented
Bastion access: Implemented
Jenkins controller setup: Implemented
Jenkins agents setup: Implemented
ECR integration: Implemented
Argo CD setup: Implemented
GitOps app bootstrap: Implemented
Monitoring setup: Implemented
Persistent storage automation: Implemented
DevSecOps tooling: Implemented
Access automation: Implemented
```

---

## Author

Built by Ahmed Rabie as part of a hands-on DevOps and Cloud Engineering portfolio project.

GitHub: `ahmedrabe33`
