# DigiPipeline Infrastructure

Production-style DevOps infrastructure platform built with Terraform, Ansible, AWS EKS, Jenkins, Argo CD, Karpenter, Amazon ECR, Prometheus, Grafana, SonarQube, and Trivy.

This repository provisions and configures a complete cloud-native delivery platform on AWS, including networking, private Kubernetes infrastructure, CI/CD infrastructure, GitOps deployment, container registry, persistent storage, monitoring, DevSecOps tooling, and secure access automation.

---

## Project Overview

DigiPipeline is a multi-repository DevOps platform designed to simulate a real-world production environment.

The project is split into three repositories:

| Repository            | Purpose                                                                        |
| --------------------- | ------------------------------------------------------------------------------ |
| `digipipeline-infra`  | Infrastructure automation using Terraform and Ansible                          |
| `digipipeline-gitops` | Kubernetes manifests, Kustomize overlays, and Argo CD deployment configuration |
| `digipipeline-app`    | Application source code, Dockerfiles, and CI build context                     |

This separation follows a real production pattern:

```text
Application code         -> digipipeline-app
Kubernetes desired state -> digipipeline-gitops
Infrastructure platform  -> digipipeline-infra
```

The goal of the project is to automate the full DevOps platform lifecycle:

```text
Build Infrastructure
  -> Configure Secure Access
  -> Install Kubernetes Platform Tools
  -> Create Application Secrets
  -> Bootstrap GitOps Application
  -> Apply Database Schema Fixes
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

All project operations are intended to be triggered from the local control machine using Ansible, not by manually SSHing into the Bastion host.

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
EBS CSI Driver installation
Default StorageClass configuration
Argo CD installation
AWS Load Balancer Controller installation
Karpenter installation
Prometheus and Grafana installation
Application secrets creation
GitOps application bootstrap
Database schema fixes
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

All project operations are triggered from the local control machine using Ansible.

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

### Application Secrets

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

```text
DB_NAME
DB_USER
DB_PASSWORD
DB_HOST
DB_PORT
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
DATABASE_URL
JWT_SECRET
REDIS_HOST
REDIS_PORT
REDIS_URL
RABBITMQ_HOST
RABBITMQ_PORT
RABBITMQ_USER
RABBITMQ_PASS
RABBITMQ_URL
AMQP_URL
```

This prevents workloads from failing with missing secret keys after a fresh rebuild.

---

### Database Schema Fixes

PostgreSQL runs as a StatefulSet and uses a PersistentVolumeClaim.

Some schema adjustments are automated after the GitOps application is deployed because the `postgres-0` pod must exist first.

The database schema playbook is:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

It is used to make the development database compatible with the current application code.

Example schema fixes include:

```text
Ensuring password_hash exists
Dropping NOT NULL from legacy password column if needed
Verifying users table structure
```

This playbook should run after:

```text
11-bootstrap-gitops-app.yml
```

---

### Persistent Storage

DigiPipeline supports persistent Kubernetes workloads using Amazon EBS volumes.

PostgreSQL uses:

```text
StatefulSet
PersistentVolumeClaim
gp3 StorageClass
AWS EBS CSI Driver
```

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
|   |   |   |-- group_vars/
|   |   |   |   |-- all.yml
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

Run all commands from the local control machine only.

```bash
cd digipipeline-infra/ansible
```

DigiPipeline is designed to be operated through one master Ansible playbook:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml
```

The master playbook runs the platform in the correct order:

```text
Prepare SSH key pairs
Verify cluster access
Install Kubernetes platform tools
Create application secrets
Bootstrap Argo CD GitOps application
Apply database schema fixes
Install Jenkins CI
Configure Jenkins plugins, agents, and ECR IAM
Install DevSecOps tools
Configure monitoring
Show access information
```

---

## Master Playbook Usage

### Normal Run

Use this when the infrastructure already exists and you want to configure or repair the platform:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml
```

This does not rebuild Terraform infrastructure and does not open local dashboard tunnels by default.

---

### Full Infrastructure Rebuild and Platform Setup

Use this after destroying infrastructure, moving to a new machine, or rebuilding the full AWS environment:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This runs Terraform infrastructure rebuild and continues with the full platform installation.

The flow includes:

```text
00-ensure-keypairs.yml
00-rebuild-infra.yml
00-verify-cluster.yml
10-install-platform.yml
02-argocd-password.yml
13-create-app-secrets.yml
11-bootstrap-gitops-app.yml
14-apply-db-schema.yml
30-install-ci.yml
29-install-jenkins-github-plugins.yml
32-configure-jenkins-ecr-iam.yml
32-configure-jenkins-agents.yml
31-install-devsecops.yml
28-install-jenkins-sonarqube-plugin.yml
27-setup-sonarqube-for-jenkins.yml
28-configure-prometheus.yml
12-show-access-info.yml
22-show-ci-info.yml
```

---

### Run Only Platform Layer

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags platform
```

This is useful for reinstalling or repairing:

```text
EBS CSI Driver
Default StorageClass
Argo CD
AWS Load Balancer Controller
Karpenter
Prometheus
Grafana
Application secrets
Database schema fixes
```

---

### Run Only Application and GitOps Layer

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags app
```

This is useful when you only want to recreate app secrets, bootstrap the Argo CD application, and apply DB schema fixes.

---

### Run Only CI / Jenkins Layer

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags ci
```

This installs and configures:

```text
Jenkins controller
Jenkins agents
Jenkins GitHub plugins
Jenkins ECR IAM access
Jenkins CI information
```

---

### Run Only DevSecOps Layer

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags devsecops
```

This installs and configures:

```text
SonarQube
Trivy
SonarQube Jenkins integration
SonarQube access verification
```

---

### Open Dashboards and Local Access Tunnels

Local dashboard access is intentionally not part of the default run because local ports may already be in use.

To open dashboards:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

This opens access to:

```text
Argo CD      -> http://localhost:8080
Jenkins      -> http://localhost:8082
SonarQube    -> http://localhost:9000
Grafana      -> http://localhost:3000
Prometheus   -> http://localhost:9090
```

If ports are already busy, stop old SSH tunnels first:

```bash
pkill -f "ssh -f -N" || true
```

Then run the access command again.

---

## Recommended Rebuild Flow

The recommended rebuild flow is now managed by the master playbook.

### Fresh Full Rebuild

```bash
cd digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

### Normal Repair / Re-run

```bash
cd digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml
```

### Open Access After Setup

```bash
cd digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

After a fresh rebuild, the ECR repositories may be empty. In that case, open Jenkins and run the CI pipeline to rebuild and push application images:

```text
Jenkins -> Pipeline -> Build Now
```

The Jenkins pipeline will:

```text
Build Docker images
Push images to Amazon ECR
Update image tags in digipipeline-gitops
Trigger Argo CD deployment through GitOps
```

After the pipeline finishes, verify Argo CD:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development'
```

Expected result:

```text
Synced   Healthy
```

Check application pods:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods'
```

Get the public application Load Balancer URL:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}{\"\n\"}"'
```

Open the application:

```text
http://<ALB-DNS>
```

---

## CI Build Flow

Before running a Jenkins build, make sure the application repository is committed and pushed:

```bash
cd digipipeline-app

git status
git add .
git commit -m "update application changes" || true
git push origin main
```

Open Jenkins:

```bash
cd digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

Then open:

```text
http://localhost:8082
```

Run:

```text
Jenkins -> Pipeline -> Build Now
```

After the build succeeds, Jenkins should update image tags in:

```text
digipipeline-gitops
```

Then verify:

```bash
cd digipipeline-infra/ansible

ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development'
```

Expected:

```text
Synced   Healthy
```

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

### Check application pods

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods'
```

### Check services and ingress

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get svc,ingress'
```

### Get application Load Balancer URL

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}{\"\n\"}"'
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

### Check current deployed image

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get deployment frontend -o jsonpath="{.spec.template.spec.containers[0].image}{\"\n\"}"'
```

### Check backend logs

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev logs deployment/user-auth --tail=150'
```

### Follow backend logs live

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev logs -f deployment/user-auth --tail=100'
```

### Check gateway access logs

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev logs deployment/gateway --since=20m | grep -Ei "api/auth|login|register|me|POST|GET|401|403|404|500"'
```

---

## Application Debugging

### Test login API

```bash
cd digipipeline-infra/ansible

ALB=$(ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"' | tail -1)

curl -i "http://$ALB/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","password":"your-password"}'
```

### Test current user endpoint

```bash
TOKEN="<JWT_TOKEN>"

curl -i "http://$ALB/api/auth/me" \
  -H "Authorization: Bearer $TOKEN"
```

Do not share real JWT tokens publicly or in screenshots.

### Clear browser storage after frontend auth changes

From browser console:

```js
localStorage.clear();
sessionStorage.clear();
```

Then hard refresh:

```text
Ctrl + Shift + R
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

### PostgreSQL fails with lost+found error

If PostgreSQL logs show:

```text
initdb: error: directory "/var/lib/postgresql/data" exists but is not empty
It contains a lost+found directory
```

Set:

```text
PGDATA=/var/lib/postgresql/data/pgdata
```

inside the PostgreSQL StatefulSet manifest in the GitOps repository.

Example:

```yaml
- name: PGDATA
  value: /var/lib/postgresql/data/pgdata
```

---

### Missing app-secrets

If pods fail with:

```text
secret "app-secrets" not found
```

or a specific missing key, run:

```bash
ansible-playbook playbooks/13-create-app-secrets.yml
```

Then restart affected pods:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev rollout restart deployment'
```

---

### Database schema mismatch

If backend logs show errors such as:

```text
column "password_hash" of relation "users" does not exist
```

run:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

Then retry the application request.

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
Kustomize patch error
StatefulSet immutable field change
```

To refresh Argo CD:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd patch application digipipeline-development --type merge -p "{\"metadata\":{\"annotations\":{\"argocd.argoproj.io/refresh\":\"hard\"}}}"'
```

To sync Argo CD:

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n argocd patch application digipipeline-development --type merge -p "{\"operation\":{\"sync\":{\"revision\":\"main\"}}}"'
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
terraform plan
terraform apply
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

### Jenkins is not opening locally

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

### Application returns 405 on signup or login

If the browser shows:

```text
405 Not Allowed
```

for:

```text
POST /api/auth/register
POST /api/auth/login
```

check the GitOps ingress file.

The ingress must route:

```text
/api -> gateway
/    -> frontend
```

Example:

```yaml
paths:
  - path: /api
    pathType: Prefix
    backend:
      service:
        name: gateway
        port:
          number: 80

  - path: /
    pathType: Prefix
    backend:
      service:
        name: frontend
        port:
          number: 80
```

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

Do not commit real passwords, tokens, private keys, kubeconfig files, or Terraform state files.

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
Application secrets automation: Implemented
Database schema automation: Implemented
Monitoring setup: Implemented
Persistent storage automation: Implemented
DevSecOps tooling: Implemented
Access automation: Implemented
```

---

## Author

Built by ahmedrabie as part of a hands-on DevOps and Cloud Engineering portfolio project.

GitHub: `ahmedrabe33`
