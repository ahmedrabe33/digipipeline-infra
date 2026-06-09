# DigiPipeline Infrastructure

> Fully automated DevOps infrastructure platform built with **Terraform**, **Ansible**, **AWS EKS**, **Jenkins**, **Argo CD**, **Karpenter**, **Amazon ECR**, **Prometheus**, **Grafana**, **SonarQube**, and **Trivy**.

---

## Overview

**DigiPipeline Infrastructure** is a production-style DevOps infrastructure repository designed to provision, configure, and operate a complete cloud-native delivery platform on AWS.

The main goal of this repository is automation.

The platform is built so that anyone with the required tools, AWS credentials, and repository access can rebuild and operate the whole project easily using Ansible playbooks.

This repository automates:

* AWS infrastructure provisioning
* Private EKS cluster setup
* Bastion-based secure access
* Kubernetes platform installation
* GitOps deployment with Argo CD
* Jenkins controller and agents setup
* Jenkins credentials and integrations
* Amazon ECR integration
* SonarQube and Trivy DevSecOps setup
* Monitoring with Prometheus and Grafana
* Application secrets creation
* Database schema automation
* Local dashboard access tunnels
* Application URL and credentials output

The project is designed to minimize manual work.
Most of the platform can be rebuilt, configured, and accessed using one master Ansible playbook.

---

## Project Repositories

DigiPipeline is split into three repositories to follow a real production DevOps structure.

| Repository            | Responsibility                                                         |
| --------------------- | ---------------------------------------------------------------------- |
| `digipipeline-app`    | Application source code, Dockerfiles, and Jenkins pipeline             |
| `digipipeline-gitops` | Kubernetes manifests, Kustomize overlays, and Argo CD desired state    |
| `digipipeline-infra`  | AWS infrastructure and platform automation using Terraform and Ansible |

Repository separation:

```text
Application code         -> digipipeline-app
Kubernetes desired state -> digipipeline-gitops
Infrastructure platform  -> digipipeline-infra
```

---

## What This Repository Automates

This repository automates the full DevOps platform lifecycle:

```text
Prepare SSH keys
        |
        v
Provision AWS infrastructure with Terraform
        |
        v
Configure Bastion access
        |
        v
Configure private EKS access
        |
        v
Install Kubernetes platform tools
        |
        v
Install Argo CD
        |
        v
Install AWS Load Balancer Controller
        |
        v
Install Karpenter
        |
        v
Install Prometheus and Grafana
        |
        v
Create application secrets
        |
        v
Bootstrap GitOps application
        |
        v
Apply database schema fixes
        |
        v
Install Jenkins controller
        |
        v
Prepare Jenkins agents automatically
        |
        v
Register Jenkins agents automatically
        |
        v
Configure Jenkins GitHub plugins
        |
        v
Configure Jenkins access to Amazon ECR
        |
        v
Install SonarQube and Trivy
        |
        v
Create or retrieve SonarQube token
        |
        v
Store SonarQube token inside Jenkins credentials
        |
        v
Show application URLs, dashboards, usernames, and passwords
```

---

## High-Level Architecture

```text
                              Developer
                                  |
                                  v
                           GitHub Repositories
                                  |
              ------------------------------------------------
              |                      |                       |
              v                      v                       v
      digipipeline-app       digipipeline-gitops      digipipeline-infra
              |                      |                       |
              |                      |                       v
              |                      |              Terraform + Ansible
              |                      |                       |
              |                      |                       v
              |                      |              AWS Infrastructure
              |                      |
              v                      |
        Jenkins CI/CD               |
        us-west-2                   |
              |                      |
              v                      |
       Build Docker Images          |
              |                      |
              v                      |
       Push Images to ECR           |
       us-east-1                    |
              |                      |
              v                      |
       Update GitOps Manifests -----|
                                     |
                                     v
                              Argo CD
                              us-east-1
                                     |
                                     v
                              Private EKS Cluster
                                     |
                  --------------------------------------------
                  |                    |                     |
                  v                    v                     v
           AuraWeb Workloads     Monitoring Stack      Platform Tools
           Microservices         Prometheus/Grafana    Argo CD/Karpenter
                  |
                  v
        AWS Load Balancer Controller
                  |
                  v
        Public Application Load Balancer
```

---

## Platform Screenshots

### Application Running Through AWS ALB

The AuraWeb application is exposed publicly using an AWS Application Load Balancer created by the AWS Load Balancer Controller.

![Application ALB](images/app-alb.png)

---

### Argo CD GitOps Deployment

Argo CD manages the Kubernetes desired state and keeps the application synchronized with the GitOps repository.

![Argo CD Healthy](images/argo-healthy.png)

---

### Jenkins CI/CD Pipeline

Jenkins builds application images, runs SonarQube and Trivy scans, pushes images to Amazon ECR, and updates the GitOps repository.

![Jenkins Pipeline Success](images/jenkins-success.png)

---

### Amazon ECR Images

Application Docker images are stored in Amazon ECR and referenced by Kubernetes manifests.

![Amazon ECR Images](images/ecr.png)

---

### Grafana Kubernetes Dashboard

Grafana provides Kubernetes cluster-level monitoring for CPU, memory, nodes, namespaces, pods, and resource usage.

![Grafana Dashboard](images/grafana-dashboard.png)

---

### Node Exporter Dashboard

Node Exporter provides node-level monitoring for CPU, memory, disk, network traffic, and system load.

![Node Exporter Dashboard](images/node-exporter.png)

---

## Regional Architecture

DigiPipeline uses a multi-region AWS architecture.

### Primary Platform Region

```text
us-east-1
```

This region hosts the main Kubernetes and application platform.

Main resources in `us-east-1`:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateways
* Route tables
* Bastion host
* Private Amazon EKS cluster
* Managed node group
* Karpenter node provisioning
* Amazon ECR repositories
* Argo CD
* AWS Load Balancer Controller
* Prometheus
* Grafana
* Application workloads
* Persistent volumes using Amazon EBS

---

### CI Region

```text
us-west-2
```

This region hosts the external CI infrastructure.

Main resources in `us-west-2`:

* Jenkins controller EC2 instance
* Jenkins agent EC2 instances
* Jenkins security groups
* Docker build environment
* CI-related IAM permissions

Jenkins runs in `us-west-2`, builds Docker images, and pushes them cross-region to Amazon ECR in `us-east-1`.

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
    |
    |-- EKS Worker Nodes
    |-- Application Pods
    |-- Argo CD
    |-- Prometheus
    |-- Grafana
    |-- Karpenter-provisioned nodes
```

The EKS cluster is private and is not accessed directly from the public internet.

The Bastion host is used as the controlled access point for:

* `kubectl` access
* Helm operations
* EKS troubleshooting
* Argo CD bootstrap
* Monitoring verification
* Local SSH tunnels
* Access automation

All project operations are intended to be triggered from the local control machine using Ansible.

---

## Main Components

| Component                    | Purpose                                                  |
| ---------------------------- | -------------------------------------------------------- |
| Terraform                    | Provisions AWS infrastructure                            |
| Ansible                      | Configures infrastructure and platform tools             |
| Amazon VPC                   | Provides isolated networking                             |
| Public Subnets               | Host Bastion, NAT, and public ALB                        |
| Private Subnets              | Host EKS nodes and workloads                             |
| Bastion Host                 | Secure management entry point to the private EKS cluster |
| Amazon EKS                   | Kubernetes platform for application and tools            |
| Amazon ECR                   | Container image registry                                 |
| Jenkins                      | CI/CD pipeline engine                                    |
| Jenkins Agents               | Build Docker images and run pipeline steps               |
| Argo CD                      | GitOps deployment controller                             |
| Karpenter                    | Kubernetes node autoscaling and cost optimization        |
| AWS Load Balancer Controller | Creates AWS ALB from Kubernetes Ingress                  |
| Amazon EBS CSI Driver        | Enables persistent Kubernetes storage                    |
| PostgreSQL                   | Application database                                     |
| Prometheus                   | Metrics collection                                       |
| Grafana                      | Metrics visualization                                    |
| SonarQube                    | Code quality analysis                                    |
| Trivy                        | Filesystem and container image security scanning         |

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
|   |   |
|   |   |-- dev/
|   |       |
|   |       |-- hosts.ini
|   |       |
|   |       |-- group_vars/
|   |           |
|   |           |-- all.yml
|   |
|   |-- playbooks/
|   |   |
|   |   |-- 00-ensure-keypairs.yml
|   |   |-- 00-rebuild-infra.yml
|   |   |-- 00-verify-cluster.yml
|   |   |-- 01-install-argocd.yml
|   |   |-- 02-argocd-password.yml
|   |   |-- 03-install-aws-load-balancer-controller.yml
|   |   |-- 04-install-ebs-csi-driver.yml
|   |   |-- 04-configure-default-storageclass.yml
|   |   |-- 06-install-karpenter.yml
|   |   |-- 09-install-monitoring.yml
|   |   |-- 10-install-platform.yml
|   |   |-- 11-bootstrap-gitops-app.yml
|   |   |-- 12-show-access-info.yml
|   |   |-- 13-create-app-secrets.yml
|   |   |-- 14-apply-db-schema.yml
|   |   |-- 20-install-jenkins-controller.yml
|   |   |-- 21-prepare-jenkins-agents.yml
|   |   |-- 22-show-ci-info.yml
|   |   |-- 24-install-sonarqube.yml
|   |   |-- 25-install-trivy.yml
|   |   |-- 26-open-sonarqube-access.yml
|   |   |-- 27-setup-sonarqube-for-jenkins.yml
|   |   |-- 27-verify-devsecops.yml
|   |   |-- 28-install-jenkins-sonarqube-plugin.yml
|   |   |-- 28-configure-prometheus.yml
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
|       |
|       |-- backend.tf
|       |-- main.tf
|       |-- provider.tf
|       |-- variable.tf
|       |-- outputs.tf
|       |-- terraform.tfvars.example
|       |
|       |-- modules/
|           |
|           |-- vpc/
|           |-- iam/
|           |-- eks/
|           |-- bastion/
|           |-- karpenter/
|           |-- ecr/
|           |-- jenkins/
|       |
|       |-- README.md
|
|-- images/
|   |
|   |-- app-alb.png
|   |-- argo-healthy.png
|   |-- ecr.png
|   |-- grafana-dashboard.png
|   |-- jenkins-success.png
|   |-- node-exporter.png
|
|-- .gitignore
|-- README.md
```

---

## Terraform Responsibilities

Terraform provisions the AWS infrastructure.

Terraform creates:

* VPC
* Public and private subnets
* Internet Gateway
* NAT Gateways
* Route tables
* EKS cluster
* Managed node group
* IAM roles and policies
* Bastion host
* Jenkins controller
* Jenkins agents
* Amazon ECR repositories
* Karpenter IAM resources
* EKS add-ons
* Security groups

Detailed Terraform documentation is maintained in:

```text
infra/terraform/README.md
```

---

## Ansible Responsibilities

Ansible automates the platform configuration and operational workflows.

Ansible automates:

* SSH key pair preparation
* Terraform execution
* Terraform output parsing
* Dynamic inventory updates
* Group variable updates
* Bastion configuration
* EKS kubeconfig setup
* Cluster verification
* EBS CSI Driver installation
* Default StorageClass configuration
* Argo CD installation
* AWS Load Balancer Controller installation
* Karpenter installation
* Prometheus and Grafana installation
* Application secrets creation
* GitOps application bootstrap
* Database schema fixes
* Jenkins controller installation
* Jenkins agent preparation
* Jenkins GitHub plugin setup
* Jenkins agent configuration
* Jenkins to ECR IAM configuration
* SonarQube installation
* Trivy installation
* SonarQube and Jenkins integration
* Local access tunnels
* Access information output

Detailed Ansible documentation is maintained in:

```text
ansible/README.md
```

---

## Jenkins Automation

Jenkins is configured through Ansible automation.

The project does not require manually adding Jenkins agents after every rebuild.

Ansible handles:

* Jenkins controller installation
* Jenkins agent machine preparation
* Required packages installation on agents
* SSH access between Jenkins controller and agents
* Jenkins node registration
* Jenkins agent labels
* Docker build environment preparation
* Jenkins GitHub plugins
* Jenkins access to Amazon ECR

Main playbooks:

```bash
ansible-playbook playbooks/20-install-jenkins-controller.yml
ansible-playbook playbooks/21-prepare-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-ecr-iam.yml
```

This means Jenkins agents are not added manually from the Jenkins UI.
They are prepared and attached automatically by Ansible.

---

## SonarQube and Jenkins Integration

SonarQube integration is also automated.

Ansible handles:

* Installing SonarQube
* Opening SonarQube access
* Installing Jenkins SonarQube plugin
* Creating or retrieving a SonarQube token
* Storing the SonarQube token inside Jenkins credentials
* Configuring Jenkins to use SonarQube in the pipeline

Main playbooks:

```bash
ansible-playbook playbooks/24-install-sonarqube.yml
ansible-playbook playbooks/28-install-jenkins-sonarqube-plugin.yml
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

The Jenkins pipeline then uses the stored SonarQube credential during the `SonarQube Scan` stage.

This makes the DevSecOps setup reproducible after every rebuild.

---

## CI/CD and GitOps Flow

DigiPipeline separates CI and CD responsibilities.

### CI Responsibility

Jenkins is responsible for:

* Checking out source code from `digipipeline-app`
* Installing dependencies
* Running tests and validations
* Running SonarQube analysis
* Running Trivy scans
* Building Docker images
* Pushing Docker images to Amazon ECR in `us-east-1`
* Updating image tags in `digipipeline-gitops`

---

### CD Responsibility

Argo CD is responsible for:

* Watching `digipipeline-gitops`
* Detecting Kubernetes manifest changes
* Syncing application resources to EKS
* Maintaining desired state
* Showing sync and health status

---

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

## One-Command Platform Deployment

DigiPipeline is designed to be easy to rebuild and operate.

The whole infrastructure and platform can be installed using one master Ansible playbook:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This command performs the complete setup flow:

```text
Prepare SSH keys
        |
        v
Provision infrastructure with Terraform
        |
        v
Update Ansible inventory and group variables
        |
        v
Configure Bastion and kubeconfig
        |
        v
Verify EKS cluster access
        |
        v
Install platform components
        |
        v
Install Argo CD
        |
        v
Install AWS Load Balancer Controller
        |
        v
Install Karpenter
        |
        v
Install monitoring stack
        |
        v
Create application secrets
        |
        v
Bootstrap GitOps application
        |
        v
Apply database schema automation
        |
        v
Install Jenkins CI
        |
        v
Prepare and register Jenkins agents automatically
        |
        v
Configure Jenkins plugins and ECR access
        |
        v
Install SonarQube and Trivy
        |
        v
Store SonarQube token inside Jenkins credentials
        |
        v
Print access information
```

---

## Normal Re-run Without Rebuilding Infrastructure

If the AWS infrastructure already exists and only the platform needs to be reconfigured or repaired, run:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml
```

This is useful when you want to re-run the automation without recreating Terraform infrastructure.

---

## Open All Dashboards and Show Access URLs

After the platform is installed, local dashboard access can be opened with:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

Or directly:

```bash
ansible-playbook playbooks/open-all-access.yml
```

This opens local access to the main platform tools:

| Tool       | Local URL               |
| ---------- | ----------------------- |
| Argo CD    | `http://localhost:8080` |
| Jenkins    | `http://localhost:8082` |
| SonarQube  | `http://localhost:9000` |
| Grafana    | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |

If local ports are already busy, clean old tunnels first:

```bash
pkill -f "ssh -f -N" || true
pkill -f "kubectl.*port-forward" || true
```

Then run:

```bash
ansible-playbook playbooks/open-all-access.yml
```

---

## Show URLs, Usernames, and Passwords

To print the application URL and platform credentials, run:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

These playbooks show important access information such as:

* Application URL
* Argo CD URL
* Argo CD admin password
* Jenkins URL
* Jenkins initial admin password
* Grafana URL
* Grafana username and password
* SonarQube URL
* SonarQube username and password
* ECR repository information

Typical development access values:

| Tool      | Username | Password                             |
| --------- | -------- | ------------------------------------ |
| Argo CD   | `admin`  | Printed by `12-show-access-info.yml` |
| Jenkins   | `admin`  | Printed by `22-show-ci-info.yml`     |
| Grafana   | `admin`  | `admin123`                           |
| SonarQube | `admin`  | `Admin@12345`                        |

> These are development/demo credentials. Do not commit real production passwords, tokens, private keys, or kubeconfig files to Git.

---

## Get the Public Application URL

The AuraWeb application is exposed through an AWS Application Load Balancer.

To get the public application URL:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ALB=$(ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress \
-o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
' | tail -1)

echo "http://$ALB"
```

Open the printed URL in the browser.

---

## After a Fresh Rebuild

After a fresh rebuild, Amazon ECR may be empty.

In that case, open Jenkins and run the application pipeline:

```text
Jenkins -> digipipeline job -> Build Now
```

The Jenkins pipeline will:

```text
Checkout application source code
        |
        v
Run SonarQube analysis
        |
        v
Run Trivy scans
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
Argo CD syncs the application to EKS
```

After the Jenkins build finishes, verify the deployment:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development
'

ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods
'
```

Expected result:

```text
Argo CD: Synced / Healthy
Pods: 1/1 Running
```

---

## Quick Start Summary

For a complete rebuild from scratch:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

Then run the Jenkins pipeline:

```text
http://localhost:8082
Jenkins -> digipipeline -> Build Now
```

Finally, get the application URL:

```bash
ALB=$(ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress \
-o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
' | tail -1)

echo "http://$ALB"
```

---

## Application Secrets

Application secrets are created using Ansible before GitOps workloads are deployed.

The secrets playbook is:

```bash
ansible-playbook playbooks/13-create-app-secrets.yml
```

It creates and updates the Kubernetes secret:

```text
auraweb-dev/app-secrets
```

The secret includes keys such as:

* `DB_NAME`
* `DB_USER`
* `DB_PASSWORD`
* `DB_HOST`
* `DB_PORT`
* `POSTGRES_DB`
* `POSTGRES_USER`
* `POSTGRES_PASSWORD`
* `DATABASE_URL`
* `JWT_SECRET`
* `REDIS_HOST`
* `REDIS_PORT`
* `REDIS_URL`
* `RABBITMQ_HOST`
* `RABBITMQ_PORT`
* `RABBITMQ_USER`
* `RABBITMQ_PASS`
* `RABBITMQ_URL`
* `AMQP_URL`

This prevents workloads from failing with missing secret keys after a fresh rebuild.

---

## Database Schema Automation

PostgreSQL runs as a StatefulSet and uses a PersistentVolumeClaim.

Some schema adjustments are automated after the GitOps application is deployed because the `postgres-0` pod must exist first.

The database schema playbook is:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

This playbook is used to make the development database compatible with the current application code.

Example schema tasks:

* Ensure the `users` table exists
* Ensure `password_hash` exists
* Verify `users` table structure
* Apply compatibility fixes for authentication services

This playbook should run after:

```text
11-bootstrap-gitops-app.yml
```

---

## Persistent Storage

DigiPipeline supports persistent Kubernetes workloads using Amazon EBS volumes.

PostgreSQL uses:

* StatefulSet
* PersistentVolumeClaim
* `gp3` StorageClass
* AWS EBS CSI Driver

The StorageClass configuration is automated using Ansible:

```bash
ansible-playbook playbooks/04-configure-default-storageclass.yml
```

This helps prevent PostgreSQL PVCs from staying in `Pending` state after a fresh rebuild.

---

## Monitoring

Monitoring is installed inside the EKS cluster.

The monitoring stack includes:

* Prometheus
* Grafana
* Kubernetes metrics collection
* Node Exporter metrics
* Cluster resource dashboards
* Node-level dashboards

Grafana is available locally after opening access tunnels:

```text
http://localhost:3000
```

Default development credentials:

```text
admin / admin123
```

---

## DevSecOps

The project includes DevSecOps automation using:

* SonarQube
* Trivy
* Jenkins integration
* ECR IAM configuration
* Jenkins GitHub plugin setup
* Jenkins agent configuration

The main DevSecOps automation playbook is:

```bash
ansible-playbook playbooks/31-install-devsecops.yml
```

SonarQube integration with Jenkins is automated using:

```bash
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

---

## Prerequisites

Before running the project, install and configure:

* AWS CLI
* Terraform
* Ansible
* kubectl
* Helm
* Git
* SSH client
* AWS account with required permissions
* GitHub repositories for app and GitOps manifests

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

| Service   | Purpose                          |
| --------- | -------------------------------- |
| Amazon S3 | Stores Terraform state           |
| DynamoDB  | Provides Terraform state locking |

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

## Useful Commands

### Check EKS Nodes

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" get nodes -o wide
'
```

---

### Check All Pods

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" get pods -A
'
```

---

### Check Application Pods

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods
'
```

---

### Check Services and Ingress

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get svc,ingress
'
```

---

### Get Application URL

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress \
-o jsonpath="{.status.loadBalancer.ingress[0].hostname}{\"\n\"}"
'
```

---

### Check Persistent Volume Claims

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pvc
'
```

---

### Check Current Deployed Image

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get deployment frontend \
-o jsonpath="{.spec.template.spec.containers[0].image}{\"\n\"}"
'
```

---

### Check Backend Logs

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev logs deployment/user-auth --tail=150
'
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

---

## Clean ECR Before Destroy

If ECR repositories contain images, clean them before destroying the infrastructure:

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

---

## Troubleshooting

### PostgreSQL PVC Stays Pending

Check PVC status:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pvc
'
```

Check StorageClass:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" get storageclass
'
```

Run StorageClass automation:

```bash
ansible-playbook playbooks/04-configure-default-storageclass.yml
```

---

### Missing `app-secrets`

If pods fail with:

```text
secret "app-secrets" not found
```

Run:

```bash
ansible-playbook playbooks/13-create-app-secrets.yml
```

Then restart affected pods:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev rollout restart deployment
'
```

---

### Database Schema Mismatch

If backend logs show database schema errors, run:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

Then retry the application request.

---

### Argo CD Shows OutOfSync or Degraded

Check Argo CD resources:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development \
-o jsonpath="{range .status.resources[*]}{.kind}{\"\t\"}{.namespace}{\"\t\"}{.name}{\"\t\"}{.status}{\"\t\"}{.health.status}{\"\n\"}{end}"
'
```

Common causes:

* Pending PVC
* ImagePullBackOff
* ErrImageNeverPull
* CreateContainerConfigError
* Missing Secret
* Missing ConfigMap
* Wrong image tag
* Empty ECR repository after rebuild
* Kustomize patch error
* StatefulSet immutable field change

---

### Jenkins Is Not Opening Locally

Open access tunnels:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

If local ports are busy:

```bash
pkill -f "ssh -f -N" || true
```

Then run the access command again.

---

## Security Notes

This project uses temporary public access for learning and demonstration purposes.

Recommended production improvements:

* Use private Jenkins access through VPN, SSM, or private networking
* Avoid exposing Jenkins directly to the internet
* Store secrets in AWS Secrets Manager or External Secrets Operator
* Use Jenkins credentials securely
* Enable HTTPS using ACM and Route 53
* Restrict security groups to trusted IP addresses
* Enable CloudWatch logs and Kubernetes audit logging
* Add backup and disaster recovery strategy
* Use least privilege IAM policies
* Use IRSA for Kubernetes service accounts
* Use private container registry access controls
* Enable image signing and policy enforcement

Do not commit:

* Real passwords
* Tokens
* Private keys
* kubeconfig files
* Terraform state files
* Sensitive `.tfvars` files

---

## What This Project Demonstrates

This project demonstrates practical DevOps and Cloud Engineering skills:

* Infrastructure as Code with Terraform
* Configuration automation with Ansible
* AWS multi-region infrastructure design
* AWS networking and subnet design
* Private EKS cluster provisioning
* Bastion-based secure cluster access
* CI infrastructure with Jenkins
* Jenkins controller and agent automation
* Cross-region image push to Amazon ECR
* GitOps delivery with Argo CD
* Kubernetes deployment automation
* Persistent storage using EBS and PVCs
* Monitoring with Prometheus and Grafana
* DevSecOps with SonarQube and Trivy
* Karpenter-based node provisioning
* Remote state management with S3 and DynamoDB
* End-to-end DevOps platform automation

---

## Tech Stack

| Category               | Tools                         |
| ---------------------- | ----------------------------- |
| Cloud                  | AWS                           |
| Infrastructure as Code | Terraform                     |
| Automation             | Ansible                       |
| Containers             | Docker                        |
| Orchestration          | Kubernetes / Amazon EKS       |
| CI/CD                  | Jenkins                       |
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

| Area                           | Status      |
| ------------------------------ | ----------- |
| Infrastructure automation      | Implemented |
| EKS provisioning               | Implemented |
| Bastion access                 | Implemented |
| Jenkins controller setup       | Implemented |
| Jenkins agents setup           | Implemented |
| ECR integration                | Implemented |
| Argo CD setup                  | Implemented |
| GitOps app bootstrap           | Implemented |
| Application secrets automation | Implemented |
| Database schema automation     | Implemented |
| Monitoring setup               | Implemented |
| Persistent storage automation  | Implemented |
| DevSecOps tooling              | Implemented |
| Access automation              | Implemented |

---

## Author

**Ahmed Rabie**
DevOps Engineer

GitHub: [ahmedrabe33](https://github.com/ahmedrabe33)

Built as part of the **DigiPipeline DevOps Project**.
