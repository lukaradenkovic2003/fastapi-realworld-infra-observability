# FastAPI RealWorld Infra & Observability

A production-grade, automated DevOps and Observability stack for a FastAPI RealWorld application deployed across a multi-instance AWS EC2 architecture, managed via Terraform and Ansible, and monitored with Prometheus, Grafana, Alertmanager, and Node Exporter.

---

## 🏗️ Architecture & Port Mapping

The infrastructure spans across three dedicated AWS EC2 instances managed via a single orchestration workflow:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #1 — fastapi-server                                                 │
│   • FastAPI app (port 8000, /metrics)                                   │
│   • node_exporter (port 9100, OS metrics)                               │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #2 — nexus-server                                                   │
│   • Nexus repository (Docker registry, ports 8081-8083)                 │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #3 — monitoring-server (jedan docker-compose stack)                 │
│   • Prometheus (port 9090, scraping metrics)                            │
│   • Grafana (port 3000, dashboard-i)                                    │
│   • Alertmanager (port 9093, Slack alertovi)                            │
└─────────────────────────────────────────────────────────────────────────┘

## 🛠️ Tech Stack
Application: FastAPI (RealWorld backend implementation)

Infrastructure (IaaS): AWS EC2, Terraform (terraform/)

Configuration Management: Ansible (ansible/)

Containerization: Docker & Docker Compose (docker-compose.yml.j2)

Observability & Monitoring: Prometheus, Grafana, Node Exporter, Alertmanager

Alerting: Slack Webhooks via dynamic alertmanager.yml.j2 templates

## 📁 Repository Structure


├── ansible/
│   ├── inventory/
│   │   ├── hosts.ini          # Active inventory (git-ignored for secrets)
│   │   └── hosts.ini.example  # Public template for inventory variables
│   ├── playbooks/
│   │   ├── app.yml            # FastAPI & Node Exporter deployment
│   │   ├── monitoring.yml     # Prometheus, Grafana & Alertmanager setup
│   │   └── nexus.yml          # Nexus registry configuration
│   └── roles/
│       ├── docker/            # Docker engine installation role
│       ├── monitoring/        # Monitoring stack with Jinja templates
│       └── nexus/             # Nexus setup role
├── terraform/                 # AWS infrastructure provisioners (.tf files)
├── load_test.py               # Python script for traffic simulation
└── README.md


## 🚀 Getting Started & Deployment
Prerequisites
WSL (Windows Subsystem for Linux) recommended for running Ansible.

Terraform installed locally.

SSH Private Key placed in your ~/.ssh/ directory.

1. Configure Inventory
Copy the example inventory and populate your target AWS EC2 public/private IP addresses and credentials:

cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini
2. Run Ansible Playbooks
Execute the playbooks from your WSL terminal using the defined roles path:

Deploy FastAPI Application & Node Exporter:

ANSIBLE_ROLES_PATH=./roles ansible-playbook -i inventory/hosts.ini playbooks/app.yml

Deploy Nexus Registry:

ANSIBLE_ROLES_PATH=./roles ansible-playbook -i inventory/hosts.ini playbooks/nexus.yml

Deploy Monitoring Stack (Prometheus, Grafana & Alertmanager):

ANSIBLE_ROLES_PATH=./roles ansible-playbook -i inventory/hosts.ini playbooks/monitoring.yml

## 📊 Monitoring & Alerts
Prometheus: Active metrics scraping on port 9090.

Grafana Dashboards: Visualizations and system stats available on port 3000.

Node Exporter: Exposes hardware/OS metrics (CPU, RAM, Disk, Network) on port 9100.

Slack Integration: Automated threshold alerts routed via Alertmanager (alertmanager.yml.j2) directly to the configured Slack channel.
