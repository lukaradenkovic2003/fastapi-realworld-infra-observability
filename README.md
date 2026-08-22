# FastAPI RealWorld Infra & Observability

A production-grade DevOps and observability stack for a FastAPI RealWorld application deployed across a multi-instance AWS EC2 architecture, provisioned with Terraform, configured with Ansible, and monitored using Prometheus, Grafana, Alertmanager, and Node Exporter.

## 🏗️ Architecture

The infrastructure consists of three dedicated AWS EC2 instances:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #1 — fastapi-server                                                 │
│                                                                         │
│ • FastAPI RealWorld application                                        │
│ • Application metrics: port 8000                                       │
│ • Node Exporter: port 9100                                             │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              │ Metrics
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #3 — monitoring-server                                              │
│                                                                         │
│ Docker Compose monitoring stack                                        │
│                                                                         │
│ • Prometheus: 9090                                                     │
│ • Grafana: 3000                                                        │
│ • Alertmanager: 9093                                                   │
│ • Slack alert notifications                                            │
└─────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #2 — nexus-server                                                   │
│                                                                         │
│ • Sonatype Nexus Repository                                             │
│ • Docker Registry                                                       │
│ • Ports: 8081–8083                                                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Monitoring Flow

```text
FastAPI Application
       │
       ├── /metrics ───────────────┐
       │                           │
Node Exporter                     │
       │                           │
       └──────────────┐            │
                      ▼            ▼
                 Prometheus
                      │
                      ├──────────► Grafana
                      │
                      └──────────► Alertmanager
                                      │
                                      ▼
                                   Slack
```

## 🛠️ Tech Stack

| Category                 | Technologies              |
| ------------------------ | ------------------------- |
| Application              | FastAPI                   |
| Cloud                    | AWS EC2                   |
| Infrastructure as Code   | Terraform                 |
| Configuration Management | Ansible                   |
| Containerization         | Docker, Docker Compose    |
| Container Registry       | Sonatype Nexus Repository |
| Metrics                  | Prometheus                |
| Visualization            | Grafana                   |
| System Monitoring        | Node Exporter             |
| Alerting                 | Alertmanager              |
| Notifications            | Slack Webhooks            |
| Automation               | Ansible Playbooks & Roles |
| Scripting                | Python                    |

## 📁 Repository Structure

```text
.
├── ansible/
│   ├── inventory/
│   │   ├── hosts.ini
│   │   └── hosts.ini.example
│   │
│   ├── playbooks/
│   │   ├── app.yml
│   │   ├── monitoring.yml
│   │   └── nexus.yml
│   │
│   └── roles/
│       ├── docker/
│       ├── monitoring/
│       └── nexus/
│
├── terraform/
│   └── *.tf
│
├── load_test.py
├── README.md
└── docker-compose.yml.j2
```

## 🚀 Deployment

### Prerequisites

* AWS account
* Terraform
* Ansible
* Docker
* WSL/Linux environment
* SSH private key configured for AWS EC2 access

### 1. Provision AWS Infrastructure

Use Terraform to provision the required AWS infrastructure:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

After provisioning, obtain the public/private IP addresses required for the Ansible inventory.

### 2. Configure Ansible Inventory

Create the local inventory from the provided example:

```bash
cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini
```

Configure the EC2 hosts and SSH connection variables in `hosts.ini`.

> `hosts.ini` should not be committed because it may contain environment-specific connection information.

### 3. Deploy FastAPI & Node Exporter

```bash
cd ansible

ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/app.yml
```

This deploys:

* FastAPI application
* Node Exporter
* Docker configuration

### 4. Deploy Nexus Repository

```bash
ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/nexus.yml
```

This configures the Nexus repository server used as the Docker registry.

### 5. Deploy Monitoring Stack

```bash
ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/monitoring.yml
```

The monitoring role deploys the Docker Compose stack containing:

* Prometheus
* Grafana
* Alertmanager

Configuration files are generated dynamically using Ansible/Jinja2 templates.

## 📊 Observability

### Prometheus

Prometheus collects metrics from the FastAPI application and Node Exporter.

**Default port:** `9090`

### Grafana

Grafana provides dashboards for visualizing application and infrastructure metrics.

**Default port:** `3000`

### Node Exporter

Node Exporter exposes Linux host-level metrics including:

* CPU usage
* Memory usage
* Disk usage
* Network metrics
* System load

**Default port:** `9100`

### Alertmanager

Alertmanager handles alerts generated by Prometheus and routes them to the configured notification channels.

**Default port:** `9093`

### Slack Alerts

Alertmanager is configured through the Ansible-generated:

```text
alertmanager.yml.j2
```

This allows Slack webhook configuration and alert routing to be managed as part of the infrastructure deployment.

## 🧪 Load Testing

The repository includes a Python script for generating application traffic:

```bash
python3 load_test.py
```

This can be used to generate traffic and observe application and infrastructure metrics through Prometheus and Grafana.

## 🔐 Infrastructure & Configuration Management

The project separates responsibilities between:

**Terraform**

* AWS infrastructure provisioning
* EC2 instances
* Networking and security configuration

**Ansible**

* Server configuration
* Docker installation
* Application deployment
* Nexus deployment
* Monitoring stack deployment
* Configuration templating

This separation allows infrastructure provisioning and server configuration to be automated independently.

## 🎯 Project Goals

This project demonstrates practical DevOps and SRE concepts including:

* Infrastructure as Code
* Configuration Management
* AWS EC2 infrastructure
* Containerization
* Docker Compose
* Private container registry
* Automated server provisioning
* Metrics collection
* Infrastructure monitoring
* Application observability
* Alerting and incident notification
* Infrastructure automation with Ansible
* Terraform-based cloud provisioning

## 🔗 Repository

GitHub:

https://github.com/lukaradenkovic2003/fastapi-realworld-infra-observability

