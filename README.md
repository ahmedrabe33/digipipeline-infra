# DigiPipeline Infrastructure

Production-style DevOps infrastructure project built with **Terraform**, **Ansible**, **AWS EKS**, **Jenkins**, **Argo CD**, **Karpenter**, **Prometheus**, and **Grafana**.

This repository provisions and configures a complete cloud-native delivery platform on AWS, including networking, Kubernetes, CI/CD infrastructure, GitOps deployment, container registry, monitoring, and secure access automation.

---

## Project Overview

**DigiPipeline Infrastructure** is designed to simulate a real DevOps production environment.

The infrastructure follows a clear workflow:

```text
Terraform
  -> AWS Infrastructure
  -> EKS Cluster
  -> Bastion Host
  -> Jenkins CI
  -> ECR Registry
  -> Argo CD GitOps
  -> Kubernetes Application
  -> Prometheus & Grafana Monitoring
```

The goal of this project is to automate the full platform lifecycle:

```text
Build Infrastructure -> Configure Access -> Install Platform Tools -> Deploy App -> Expose Dashboards
```

---

## Architecture

```text
                        Internet
                           |
                           |
                    Public Access
                           |
        -------------------------------------
        |                                   |
   Bastion Host                      Jenkins Controller
        |                                   |
        |                            Jenkins Agents
        |
        v
   Private EKS Cluster
        |
        |-- System Node Group
        |-- Karpenter Node Provisioning
        |-- Argo CD
        |-- Prometheus
        |-- Grafana
        |-- Application Workloads
        |
        v
   AWS Load Balancer Controller
        |
        v
   Public ALB for Application Access
```

---

## Main Components

### Infrastructure as Code

Terraform is used to provision:

* VPC
* Public and private subnets
* Internet Gateway
* NAT Gateways
* Route tables
* EKS cluster
* Managed node group
* IAM roles and policies
* Bastion host
* Jenkins controller and agents
* ECR repositories
* Karpenter IAM resources

### Configuration Management

Ansible is used to automate:

* Terraform apply and output parsing
* Dynamic inventory updates
* Bastion configuration
* EKS kubeconfig setup
* Jenkins installation
* Argo CD installation
* Monitoring stack installation
* GitOps application bootstrap
* Access information output
* Local access tunnels for Argo CD, Prometheus, and Jenkins

### Kubernetes Platform

The EKS platform includes:

* Argo CD for GitOps
* AWS Load Balancer Controller
* Prometheus for metrics collection
* Grafana for dashboards
* Karpenter for dynamic node provisioning
* Demo application deployed through GitOps

---

## Repository Structure

```text
digipipeline-infra/
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/
│   │   └── dev/
│   │       └── hosts.ini
│   ├── group_vars/
│   └── playbooks/
│       ├── 00-rebuild-infra.yml
│       ├── 10-install-platform.yml
│       ├── 11-bootstrap-gitops-app.yml
│       ├── 12-show-access-info.yml
│       ├── 22-show-ci-info.yml
│       ├── 30-install-ci.yml
│       └── open-all-access.yml
│
├── infra/
│   └── terraform/
│       ├── backend.tf
│       ├── main.tf
│       ├── provider.tf
│       ├── variable.tf
│       ├── outputs.tf
│       ├── terraform.tfvars.example
│       └── modules/
│           ├── vpc/
│           ├── iam/
│           ├── eks/
│           ├── bastion/
│           ├── karpenter/
│           ├── ecr/
│           └── jenkins/
│
├── .gitignore
└── README.md
```

---

## Related Repositories

This infrastructure repository works together with:

| Repository            | Purpose                                               |
| --------------------- | ----------------------------------------------------- |
| `digipipeline-infra`  | Infrastructure automation using Terraform and Ansible |
| `digipipeline-gitops` | Kubernetes manifests watched by Argo CD               |
| `digipipeline-app`    | Application source code and Docker build context      |

---

## Prerequisites

Before running the project, install and configure:

* AWS CLI
* Terraform
* Ansible
* kubectl
* SSH key pair for EC2 access
* AWS account with required permissions
* GitHub repositories for app and GitOps manifests

Check AWS identity:

```bash
aws sts get-caller-identity
```

Check tools:

```bash
terraform version
ansible --version
kubectl version --client
aws --version
```

---

## Terraform Backend

Terraform uses a remote backend with:

* S3 bucket for state storage
* DynamoDB table for state locking

Example backend structure:

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

> Do not delete the backend S3 bucket or DynamoDB lock table unless you intentionally want to remove Terraform state management.

---

## How to Deploy

### 1. Clone the repository

```bash
git clone https://github.com/ahmedrabe33/digipipeline-infra.git
cd digipipeline-infra
```

### 2. Configure Terraform variables

Create your local variables file:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Update values such as:

```hcl
key_name   = "your-key-name"
my_ip_cidr = "your-public-ip/32"
```

### 3. Rebuild the full infrastructure

Run from the Ansible directory:

```bash
cd ../../ansible
ansible-playbook playbooks/00-rebuild-infra.yml
```

This playbook will:

* Run Terraform init, fmt, validate, and apply
* Read Terraform outputs
* Update Ansible inventory
* Configure kubeconfig on the Bastion host
* Verify EKS nodes are ready

Expected output:

```text
Infrastructure is ready.
Bastion IP: x.x.x.x
```

---

## Install Jenkins CI

After the infrastructure is ready:

```bash
ansible-playbook playbooks/30-install-ci.yml
```

Show Jenkins access information:

```bash
ansible-playbook playbooks/22-show-ci-info.yml
```

---

## Install Kubernetes Platform

Install Argo CD, monitoring, and platform tools:

```bash
ansible-playbook playbooks/10-install-platform.yml
```

Bootstrap the GitOps application:

```bash
ansible-playbook playbooks/11-bootstrap-gitops-app.yml
```

Show application, Argo CD, and Grafana access information:

```bash
ansible-playbook playbooks/12-show-access-info.yml
```

---

## Open Argo CD, Prometheus, and Jenkins

To open all local access tunnels automatically:

```bash
ansible-playbook playbooks/open-all-access.yml
```

This opens:

| Tool       | Local URL                |
| ---------- | ------------------------ |
| Argo CD    | `https://localhost:8080` |
| Prometheus | `http://localhost:9090`  |
| Jenkins    | `http://localhost:8082`  |

The playbook also prints usernames and passwords when available.

---

## Useful Commands

### Check EKS nodes from Bastion

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

### Check monitoring services

```bash
ansible bastion -m shell -a 'kubectl --kubeconfig "$HOME/.kube/config" -n monitoring get svc'
```

---

## Destroy Infrastructure

To destroy all Terraform-managed resources:

```bash
cd infra/terraform

terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

After destroy, verify:

```bash
terraform state list
```

Check AWS resources:

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

  aws ec2 describe-vpcs \
    --region $REGION \
    --profile default \
    --filters "Name=tag:Project,Values=digipipeline" \
    --query "Vpcs[].{Name:Tags[?Key=='Name']|[0].Value,VpcId:VpcId,State:State}" \
    --output table
done
```

---

## Security Notes

This project uses temporary public access for learning and demonstration purposes.

Recommended production improvements:

* Use private Jenkins access only through VPN or SSM
* Avoid exposing Jenkins directly to the internet
* Store secrets in AWS Secrets Manager or External Secrets Operator
* Use GitHub Actions or Jenkins credentials securely
* Enable HTTPS with ACM and Route 53
* Restrict security groups to trusted IPs
* Enable CloudWatch logs and audit logging
* Add backup and disaster recovery strategy
* Use least privilege IAM policies

---

## What This Project Demonstrates

This project demonstrates practical DevOps and Cloud Engineering skills:

* Infrastructure as Code with Terraform
* Configuration automation with Ansible
* AWS networking design
* EKS cluster provisioning
* CI infrastructure with Jenkins
* GitOps delivery with Argo CD
* Kubernetes deployment automation
* Monitoring with Prometheus and Grafana
* Secure access through Bastion and SSH tunnels
* Remote state management with S3 and DynamoDB
* End-to-end DevOps platform automation

---

## Tech Stack

| Category      | Tools                     |
| ------------- | ------------------------- |
| Cloud         | AWS                       |
| IaC           | Terraform                 |
| Automation    | Ansible                   |
| Containers    | Docker                    |
| Orchestration | Kubernetes / EKS          |
| CI            | Jenkins                   |
| GitOps        | Argo CD                   |
| Registry      | Amazon ECR                |
| Monitoring    | Prometheus                |
| Dashboards    | Grafana                   |
| Scaling       | Karpenter                 |
| Access        | Bastion Host / SSH Tunnel |

---

## Status

Current project status:

```text
Infrastructure automation: Complete
EKS provisioning: Complete
Bastion access: Complete
Jenkins setup: Complete
Argo CD setup: Complete
Monitoring setup: Complete
GitOps app bootstrap: Complete
Access automation: Complete
```

---

## Author

Built by **Ahmed Rabie** as part of a hands-on DevOps and Cloud Engineering portfolio project.

GitHub: [ahmedrabe33](https://github.com/ahmedrabe33)
