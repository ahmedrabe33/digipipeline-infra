# DigiPipeline Ansible Automation

> Ansible automation layer for building, configuring, operating, and accessing the DigiPipeline DevOps platform.

---

## Overview

This directory contains the Ansible automation used to configure and operate the DigiPipeline platform after the AWS infrastructure is created by Terraform.

The main goal of this Ansible project is to make the platform easy to run, rebuild, repair, and access with minimal manual steps.

Ansible is responsible for:

* Running Terraform when needed
* Reading Terraform outputs
* Updating Ansible inventory automatically
* Configuring Bastion access
* Configuring private EKS access
* Installing Kubernetes platform tools
* Installing Argo CD
* Installing AWS Load Balancer Controller
* Installing Karpenter
* Installing Prometheus and Grafana
* Creating application secrets
* Bootstrapping the GitOps application
* Applying database schema fixes
* Installing Jenkins controller
* Preparing Jenkins agents
* Registering Jenkins agents automatically
* Installing Jenkins plugins
* Configuring Jenkins access to Amazon ECR
* Installing SonarQube
* Installing Trivy
* Creating or retrieving SonarQube token
* Storing SonarQube token inside Jenkins credentials automatically
* Opening local dashboard access
* Printing URLs, usernames, and passwords

The platform is designed so that anyone with the required prerequisites can run the project easily using the master Ansible playbook.

---

## Main Idea

Terraform creates the AWS infrastructure.

Ansible configures everything on top of that infrastructure.

```text
Terraform
   |
   v
Creates AWS infrastructure
   |
   v
Ansible
   |
   v
Configures Bastion, EKS, Jenkins, GitOps, Monitoring, DevSecOps, and Access
```

---

## Recommended Usage

Run Ansible from this directory:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible
```

For a complete build from scratch:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This is the main command for building the full platform.

---

## What the Master Playbook Does

The master playbook is:

```bash
playbooks/99-run-all-digipipeline.yml
```

It automates the full platform lifecycle:

```text
Prepare SSH keys
        |
        v
Run Terraform infrastructure build
        |
        v
Read Terraform outputs
        |
        v
Update inventory and group variables
        |
        v
Configure Bastion access
        |
        v
Configure private EKS kubeconfig
        |
        v
Verify EKS cluster
        |
        v
Install EBS CSI Driver and StorageClass
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
Bootstrap Argo CD GitOps application
        |
        v
Apply database schema fixes
        |
        v
Install Jenkins controller
        |
        v
Prepare Jenkins agents
        |
        v
Register Jenkins agents automatically
        |
        v
Install Jenkins GitHub plugins
        |
        v
Configure Jenkins access to Amazon ECR
        |
        v
Install SonarQube
        |
        v
Install Trivy
        |
        v
Store SonarQube token inside Jenkins credentials
        |
        v
Show access URLs and credentials
```

---

## Quick Start

### Complete Build From Scratch

Use this command when you want to build the full infrastructure and platform:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

This runs Terraform and then configures the whole platform.

---

### Normal Re-run Without Rebuilding Infrastructure

Use this when the AWS infrastructure already exists and you only want to repair or reconfigure the platform:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml
```

---

### Open All Dashboards

Use this after the platform is installed:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

Or run the access playbook directly:

```bash
ansible-playbook playbooks/open-all-access.yml
```

This opens local access to:

| Tool       | Local URL               |
| ---------- | ----------------------- |
| Argo CD    | `http://localhost:8080` |
| Jenkins    | `http://localhost:8082` |
| SonarQube  | `http://localhost:9000` |
| Grafana    | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |

---

### Show URLs, Usernames, and Passwords

To print access information:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

These playbooks show:

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

Typical development credentials:

| Tool      | Username | Password                             |
| --------- | -------- | ------------------------------------ |
| Argo CD   | `admin`  | Printed by `12-show-access-info.yml` |
| Jenkins   | `admin`  | Printed by `22-show-ci-info.yml`     |
| Grafana   | `admin`  | `admin123`                           |
| SonarQube | `admin`  | `Admin@12345`                        |

> These are development/demo credentials. Do not use them as production secrets.

---

## Directory Structure

```text
ansible/
|
|-- ansible.cfg
|
|-- inventories/
|   |
|   |-- dev/
|       |
|       |-- hosts.ini
|       |
|       |-- group_vars/
|           |
|           |-- all.yml
|
|-- playbooks/
|   |
|   |-- 00-ensure-keypairs.yml
|   |-- 00-rebuild-infra.yml
|   |-- 00-verify-cluster.yml
|   |
|   |-- 01-install-argocd.yml
|   |-- 02-argocd-password.yml
|   |-- 03-install-aws-load-balancer-controller.yml
|   |-- 04-install-ebs-csi-driver.yml
|   |-- 04-configure-default-storageclass.yml
|   |-- 06-install-karpenter.yml
|   |-- 09-install-monitoring.yml
|   |-- 10-install-platform.yml
|   |
|   |-- 11-bootstrap-gitops-app.yml
|   |-- 12-show-access-info.yml
|   |-- 13-create-app-secrets.yml
|   |-- 14-apply-db-schema.yml
|   |
|   |-- 20-install-jenkins-controller.yml
|   |-- 21-prepare-jenkins-agents.yml
|   |-- 22-show-ci-info.yml
|   |-- 24-install-sonarqube.yml
|   |-- 25-install-trivy.yml
|   |-- 26-open-sonarqube-access.yml
|   |-- 27-setup-sonarqube-for-jenkins.yml
|   |-- 27-verify-devsecops.yml
|   |-- 28-install-jenkins-sonarqube-plugin.yml
|   |-- 28-configure-prometheus.yml
|   |-- 29-install-jenkins-github-plugins.yml
|   |-- 30-install-ci.yml
|   |-- 31-install-devsecops.yml
|   |-- 32-configure-jenkins-agents.yml
|   |-- 32-configure-jenkins-ecr-iam.yml
|   |
|   |-- open-all-access.yml
|   |-- 99-run-all-digipipeline.yml
|
|-- README.md
```

---

## Inventory

The main inventory file is:

```text
inventories/dev/hosts.ini
```

This file contains the hosts used by Ansible, such as:

* Bastion host
* Jenkins controller
* Jenkins agents

Ansible updates inventory values after Terraform creates or rebuilds the infrastructure.

---

## Group Variables

The main variables file is:

```text
inventories/dev/group_vars/all.yml
```

It contains shared project variables such as:

* AWS regions
* EKS cluster name
* Key paths
* Jenkins configuration
* GitOps repository settings
* ECR information
* Application namespace
* Dashboard ports
* Tool credentials for the development environment

---

## AWS Regions

DigiPipeline uses two AWS regions.

### `us-east-1`

Main platform region.

Contains:

* VPC
* Bastion host
* Private EKS cluster
* EKS worker nodes
* Amazon ECR
* Argo CD
* Karpenter
* Prometheus
* Grafana
* Application workloads
* PostgreSQL
* Redis
* RabbitMQ
* MinIO

### `us-west-2`

CI region.

Contains:

* Jenkins controller EC2
* Jenkins agent EC2 instances
* Jenkins CI infrastructure

Jenkins builds Docker images in `us-west-2` and pushes them cross-region to Amazon ECR in `us-east-1`.

---

## Playbook Categories

### Infrastructure Playbooks

| Playbook                 | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| `00-ensure-keypairs.yml` | Creates or validates required SSH key pairs |
| `00-rebuild-infra.yml`   | Runs Terraform and rebuilds infrastructure  |
| `00-verify-cluster.yml`  | Verifies EKS access and cluster health      |

---

### Platform Playbooks

| Playbook                                      | Purpose                                       |
| --------------------------------------------- | --------------------------------------------- |
| `01-install-argocd.yml`                       | Installs Argo CD                              |
| `02-argocd-password.yml`                      | Prints Argo CD initial admin password         |
| `03-install-aws-load-balancer-controller.yml` | Installs AWS Load Balancer Controller         |
| `04-install-ebs-csi-driver.yml`               | Installs EBS CSI Driver                       |
| `04-configure-default-storageclass.yml`       | Configures default StorageClass               |
| `06-install-karpenter.yml`                    | Installs Karpenter                            |
| `09-install-monitoring.yml`                   | Installs Prometheus and Grafana               |
| `10-install-platform.yml`                     | Runs platform installation playbooks together |

---

### Application and GitOps Playbooks

| Playbook                      | Purpose                                           |
| ----------------------------- | ------------------------------------------------- |
| `11-bootstrap-gitops-app.yml` | Creates Argo CD application                       |
| `12-show-access-info.yml`     | Shows application and platform access information |
| `13-create-app-secrets.yml`   | Creates application Kubernetes secrets            |
| `14-apply-db-schema.yml`      | Applies database schema compatibility fixes       |

---

### Jenkins and CI Playbooks

| Playbook                                | Purpose                                 |
| --------------------------------------- | --------------------------------------- |
| `20-install-jenkins-controller.yml`     | Installs Jenkins controller             |
| `21-prepare-jenkins-agents.yml`         | Prepares Jenkins agent machines         |
| `22-show-ci-info.yml`                   | Shows Jenkins and CI access information |
| `29-install-jenkins-github-plugins.yml` | Installs Jenkins GitHub plugins         |
| `30-install-ci.yml`                     | Runs Jenkins CI setup                   |
| `32-configure-jenkins-agents.yml`       | Registers Jenkins agents automatically  |
| `32-configure-jenkins-ecr-iam.yml`      | Configures Jenkins access to Amazon ECR |

---

### DevSecOps Playbooks

| Playbook                                  | Purpose                                           |
| ----------------------------------------- | ------------------------------------------------- |
| `24-install-sonarqube.yml`                | Installs SonarQube                                |
| `25-install-trivy.yml`                    | Installs Trivy                                    |
| `26-open-sonarqube-access.yml`            | Opens SonarQube access                            |
| `27-setup-sonarqube-for-jenkins.yml`      | Stores SonarQube token inside Jenkins credentials |
| `27-verify-devsecops.yml`                 | Verifies DevSecOps tools                          |
| `28-install-jenkins-sonarqube-plugin.yml` | Installs Jenkins SonarQube plugin                 |
| `31-install-devsecops.yml`                | Runs DevSecOps setup together                     |

---

### Monitoring and Access Playbooks

| Playbook                      | Purpose                                   |
| ----------------------------- | ----------------------------------------- |
| `28-configure-prometheus.yml` | Configures Prometheus monitoring          |
| `open-all-access.yml`         | Opens local access tunnels for dashboards |

---

## Tags

The master playbook supports tags to run specific parts of the automation.

### Full Infrastructure and Platform Build

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

### Platform Only

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags platform
```

### Application and GitOps Only

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags app
```

### CI / Jenkins Only

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags ci
```

### DevSecOps Only

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags devsecops
```

### Access Only

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

---

## Jenkins Automation

Jenkins is fully automated through Ansible.

Ansible handles:

* Installing Jenkins controller
* Starting Jenkins using Docker
* Getting the initial Jenkins password
* Preparing Jenkins agents
* Installing Java, Docker, Git, and AWS CLI on agents
* Configuring SSH access between controller and agents
* Registering Jenkins agents automatically
* Installing required Jenkins plugins
* Configuring Jenkins access to Amazon ECR

This means Jenkins agents do not need to be added manually from the Jenkins UI after every rebuild.

Main commands:

```bash
ansible-playbook playbooks/30-install-ci.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-ecr-iam.yml
```

---

## SonarQube Automation

SonarQube integration with Jenkins is automated.

Ansible handles:

* Installing SonarQube
* Opening SonarQube access
* Installing the Jenkins SonarQube plugin
* Creating or retrieving a SonarQube token
* Storing the SonarQube token inside Jenkins credentials
* Making the token available for Jenkins pipelines

Main commands:

```bash
ansible-playbook playbooks/24-install-sonarqube.yml
ansible-playbook playbooks/28-install-jenkins-sonarqube-plugin.yml
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

The user does not need to manually copy the SonarQube token into Jenkins after every rebuild.

---

## Application Secrets Automation

Application secrets are created automatically by Ansible.

Main playbook:

```bash
ansible-playbook playbooks/13-create-app-secrets.yml
```

It creates the secret:

```text
auraweb-dev/app-secrets
```

The secret contains values required by the application, including:

* Database variables
* Redis variables
* RabbitMQ variables
* JWT secret
* Application connection strings

This prevents application pods from failing because of missing secrets.

---

## Database Schema Automation

The database schema playbook is:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

It applies required schema fixes after the PostgreSQL pod is running.

This helps keep the database compatible with the current application version after a fresh rebuild.

---

## Access Automation

Dashboard access is automated using:

```bash
ansible-playbook playbooks/open-all-access.yml
```

This opens access to the main tools through local ports.

| Tool       | Local URL               |
| ---------- | ----------------------- |
| Argo CD    | `http://localhost:8080` |
| Jenkins    | `http://localhost:8082` |
| SonarQube  | `http://localhost:9000` |
| Grafana    | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |

If ports are already in use, clean old tunnels:

```bash
pkill -f "ssh -f -N" || true
pkill -f "kubectl.*port-forward" || true
```

Then open access again:

```bash
ansible-playbook playbooks/open-all-access.yml
```

---

## Get Application URL

To get the public application URL:

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ALB=$(ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get ingress auraweb-ingress \
-o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
' | tail -1)

echo "http://$ALB"
```

---

## Verify Platform

### Verify EKS Nodes

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" get nodes -o wide
'
```

### Verify All Pods

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" get pods -A
'
```

### Verify Application Pods

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods
'
```

### Verify Argo CD Application

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development
'
```

Expected result:

```text
Synced   Healthy
```

---

## After a Fresh Rebuild

After a fresh infrastructure rebuild, Amazon ECR may be empty.

In that case:

1. Open Jenkins.
2. Run the application pipeline.
3. Jenkins builds Docker images.
4. Jenkins pushes images to Amazon ECR.
5. Jenkins updates the GitOps repository.
6. Argo CD syncs the new images to EKS.

Open Jenkins:

```text
http://localhost:8082
```

Run:

```text
Jenkins -> digipipeline -> Build Now
```

---

## Typical Workflow

### Build Everything

```bash
cd ~/digipipeline-workspace/digipipeline-infra/ansible

ansible-playbook playbooks/99-run-all-digipipeline.yml --tags "infra,all"
```

### Open Dashboards

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

### Show Credentials

```bash
ansible-playbook playbooks/12-show-access-info.yml
ansible-playbook playbooks/22-show-ci-info.yml
```

### Run Jenkins Pipeline

```text
http://localhost:8082
Jenkins -> digipipeline -> Build Now
```

### Verify Application

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods
'
```

---

## Troubleshooting

### Old Local Tunnels Are Running

Clean old tunnels:

```bash
pkill -f "ssh -f -N" || true
pkill -f "kubectl.*port-forward" || true
```

Then open access again:

```bash
ansible-playbook playbooks/open-all-access.yml
```

---

### Argo CD Is Not Synced

Check the Argo CD application:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development
'
```

Check detailed resource status:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n argocd get application digipipeline-development \
-o jsonpath="{range .status.resources[*]}{.kind}{\"\t\"}{.namespace}{\"\t\"}{.name}{\"\t\"}{.status}{\"\t\"}{.health.status}{\"\n\"}{end}"
'
```

---

### Application Pods Are Not Running

Check pods:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get pods -o wide
'
```

Check events:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev get events --sort-by=.lastTimestamp | tail -40
'
```

---

### Missing Application Secrets

Run:

```bash
ansible-playbook playbooks/13-create-app-secrets.yml
```

Then restart deployments:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev rollout restart deployment
'
```

---

### Database Schema Errors

Run:

```bash
ansible-playbook playbooks/14-apply-db-schema.yml
```

Then check backend logs:

```bash
ansible bastion -m shell -a '
kubectl --kubeconfig "$HOME/.kube/config" -n auraweb-dev logs deployment/user-auth --tail=150
'
```

---

### Jenkins Is Not Opening

Open access:

```bash
ansible-playbook playbooks/99-run-all-digipipeline.yml --tags access
```

Or:

```bash
ansible-playbook playbooks/open-all-access.yml
```

---

### Jenkins Agents Are Missing

Run:

```bash
ansible-playbook playbooks/21-prepare-jenkins-agents.yml
ansible-playbook playbooks/32-configure-jenkins-agents.yml
```

---

### SonarQube Token Is Missing from Jenkins

Run:

```bash
ansible-playbook playbooks/28-install-jenkins-sonarqube-plugin.yml
ansible-playbook playbooks/27-setup-sonarqube-for-jenkins.yml
```

This recreates or retrieves the SonarQube token and stores it inside Jenkins credentials automatically.

---

## Security Notes

Do not commit:

* SSH private keys
* AWS credentials
* Jenkins passwords
* SonarQube tokens
* kubeconfig files
* Terraform state files
* Sensitive variables

Recommended production improvements:

* Use AWS Secrets Manager or External Secrets Operator
* Restrict SSH and dashboard access to trusted IPs
* Use private access through VPN or AWS SSM
* Enable HTTPS using ACM and Route 53
* Rotate Jenkins and SonarQube credentials
* Use least privilege IAM policies
* Avoid public Jenkins exposure in production

---

## What This Ansible Project Demonstrates

This Ansible project demonstrates:

* Infrastructure automation orchestration
* Terraform and Ansible integration
* Dynamic inventory updates
* Bastion-based EKS access
* Kubernetes platform automation
* GitOps bootstrapping
* Jenkins automation
* Jenkins agent automation
* DevSecOps automation
* SonarQube token automation
* Monitoring automation
* Application secrets automation
* Database schema automation
* Access tunnel automation
* Reproducible DevOps platform setup

---

## Author

**Ahmed Rabie**
DevOps Engineer

GitHub: [ahmedrabe33](https://github.com/ahmedrabe33)

Built as part of the **DigiPipeline DevOps Project**.
