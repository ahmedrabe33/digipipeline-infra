# DevOps Production Platform on AWS EKS

A production-like DevOps platform built on AWS to run and manage cloud-native microservices workloads using Kubernetes, Infrastructure as Code, GitOps, autoscaling, CI/CD, and monitoring practices.

This project focuses on building the platform infrastructure and delivery workflow around a real microservices application workload.

---

## Project Overview

The goal of this project is to design and implement a production-like DevOps platform on AWS.

The platform is built around a private Amazon EKS cluster provisioned with Terraform. Administrative access is handled through a Bastion Host, while application delivery is planned to be managed using Argo CD and GitOps.

The workload is based on selected services from Google's Online Boutique microservices demo, adapted to run on AWS EKS.

---

## Main Objectives

- Build secure AWS infrastructure using Terraform
- Run a private Amazon EKS cluster
- Use a Bastion Host for cluster administration
- Configure Karpenter for node autoscaling
- Use Argo CD for GitOps-based Continuous Delivery
- Use Jenkins for CI pipelines
- Deploy a real microservices workload
- Add autoscaling using HPA and Karpenter
- Add monitoring using Prometheus and Grafana
- Follow production-like security and architecture practices

---

## High-Level Architecture

```text
Developer
   |
   | git push
   v
GitHub App Repository
   |
   v
Jenkins CI Pipeline
   |
   | build / test / scan / push image
   v
Container Registry
   |
   | update image tag
   v
GitOps Repository
   |
   v
Argo CD
   |
   v
Private Amazon EKS Cluster
   |
   ├── Application workloads
   ├── Karpenter node autoscaling
   ├── AWS Load Balancer Controller
   └── Monitoring stack
```

---

## AWS Infrastructure Architecture

```text
VPC: 10.0.0.0/16

Availability Zone A
├── Public Subnet
│   ├── Bastion Host
│   └── NAT Gateway
│
└── Private Subnet
    └── EKS Worker Node

Availability Zone B
├── Public Subnet
│   └── NAT Gateway
│
└── Private Subnet
    └── EKS Worker Node
```

---

## Access Model

### Admin Access

```text
Admin Machine
   |
   | SSH
   v
Bastion Host
   |
   | kubectl / helm
   v
Private EKS API Endpoint
```

The Kubernetes API endpoint is private and is not exposed directly to the public internet.

### Application Access

```text
Users
   |
   v
Public ALB
   |
   v
Kubernetes Ingress
   |
   v
Service
   |
   v
Pods running on private worker nodes
```

---

## Application Workload

This project uses selected services from Google's Online Boutique microservices demo as a realistic cloud-native e-commerce workload.

The application is used to demonstrate how the platform handles:

- Kubernetes deployments
- Service-to-service communication
- GitOps delivery
- Ingress through AWS ALB
- Pod autoscaling
- Node autoscaling
- Monitoring and observability

Planned selected services:

- frontend
- productcatalogservice
- cartservice
- redis-cart

The main focus of this project is not building the application itself, but building the DevOps platform that runs, scales, deploys, and monitors it.

---

## Tools and Technologies

- AWS
- Terraform
- Amazon EKS
- Amazon VPC
- EC2 Bastion Host
- IAM
- S3 Remote Backend
- DynamoDB State Locking
- Kubernetes
- Karpenter
- Argo CD
- Jenkins
- Docker
- Trivy
- SonarQube
- AWS Load Balancer Controller
- Prometheus
- Grafana

---

## Project Stages

### Stage 1 — Terraform Infrastructure

Provision the AWS infrastructure using Terraform.

Includes:

- Remote backend using S3 and DynamoDB
- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateways
- IAM roles
- Private EKS cluster
- Managed node group
- Bastion Host
- Karpenter IAM setup

---

### Stage 2 — Cluster Bootstrap

Configure the Kubernetes cluster from the Bastion Host.

Includes:

- kubeconfig setup
- Karpenter installation
- EC2NodeClass
- NodePool
- Argo CD installation
- AWS Load Balancer Controller installation

---

### Stage 3 — GitOps with Argo CD

Use Argo CD to manage Kubernetes application delivery.

```text
GitOps Repository
   |
   v
Argo CD
   |
   v
Amazon EKS
```

Jenkins will not deploy directly to Kubernetes. Argo CD will pull the desired state from the GitOps repository and sync it to the cluster.

---

### Stage 4 — Application Deployment

Deploy selected Online Boutique services to Amazon EKS.

Initial services:

- frontend
- productcatalogservice
- cartservice
- redis-cart

---

### Stage 5 — CI Pipeline with Jenkins

Jenkins will handle Continuous Integration.

Planned pipeline:

- Checkout source code
- Run tests
- Run SonarQube scan
- Build Docker image
- Scan image with Trivy
- Push image to container registry
- Update GitOps repository

---

### Stage 6 — Autoscaling

The platform will use two levels of autoscaling:

```text
HPA       → scales Pods
Karpenter → scales Nodes
```

Scaling flow:

```text
Traffic increases
   |
   v
HPA creates more pods
   |
   v
Some pods become Pending
   |
   v
Karpenter provisions new worker nodes
   |
   v
Pending pods get scheduled
```

---

### Stage 7 — Monitoring

Monitoring will be added using:

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- Node Exporter

Monitoring will be used to observe:

- Node CPU and memory
- Pod CPU and memory
- Kubernetes deployments
- HPA behavior
- Karpenter node scaling
- Application health

---

## Current Progress

Completed:

- Terraform remote backend using S3
- Terraform state locking using DynamoDB
- Modular Terraform infrastructure
- Highly available VPC across two Availability Zones
- Public and private subnets
- NAT Gateways
- Private Amazon EKS cluster
- Managed EKS node group
- Bastion Host
- IAM roles for EKS, worker nodes, and Bastion
- Karpenter IAM and OIDC setup
- Bastion access to private EKS cluster
- Manual Karpenter installation and scaling test
- Initial Argo CD installation and private access test

---

## Repository Structure

```text
devops-production-platform/
│
├── README.md
│
└── infra/
    └── terraform/
        ├── backend-bootstrap/
        ├── backend.tf
        ├── provider.tf
        ├── variable.tf
        ├── terraform.tfvars
        ├── main.tf
        ├── outputs.tf
        │
        └── modules/
            ├── vpc/
            ├── iam/
            ├── eks/
            ├── bastion/
            └── karpenter/
```

More directories will be added later for:

```text
ansible/
gitops-repo/
app-repo/
jenkins/
monitoring/
```

---

## Security Practices

This project follows several production-like security practices:

- Private EKS API endpoint
- Worker nodes in private subnets
- Bastion Host for administrative access
- SSH access restricted to allowed IPs
- IAM roles instead of hardcoded access keys
- No direct SSH access to worker nodes
- Terraform remote state stored in S3
- Terraform state locking using DynamoDB
- Sensitive files excluded from Git
- Argo CD UI accessed privately through SSH tunnel

---

## Sensitive Files

The following files must never be pushed to GitHub:

```text
credentials
config
*.pem
*.tfstate
*.tfstate.*
tfplan
.terraform/
```

These files should be ignored using `.gitignore`.

---

## Cost Warning

This project creates paid AWS resources, including:

- Amazon EKS cluster
- NAT Gateways
- EC2 worker nodes
- Bastion Host
- S3 bucket
- DynamoDB table

To avoid unnecessary cost, destroy the infrastructure when not in use.

```bash
terraform destroy
```

If the remote backend is no longer needed, destroy the backend-bootstrap resources only after destroying the main infrastructure.

---

## Project Goal

The main goal of this project is to demonstrate the ability to design and implement a production-like DevOps platform on AWS using modern cloud-native tools.

This project demonstrates:

- Infrastructure as Code
- Secure cloud networking
- Kubernetes operations
- GitOps deployment
- CI/CD automation
- Autoscaling
- Monitoring
- Production-oriented architecture
