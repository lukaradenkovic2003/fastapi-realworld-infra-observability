# FastAPI RealWorld Infra & Observability

A production-oriented DevOps and observability infrastructure for a FastAPI RealWorld application running across a multi-instance AWS EC2 architecture.

The infrastructure is provisioned with **Terraform**, configured and deployed with **Ansible**, containerized with **Docker**, and monitored using **Prometheus, Grafana, Node Exporter, and Alertmanager**, with Slack notifications for triggered alerts.

The application itself is maintained in a separate repository, where the CI/CD pipeline builds and publishes the Docker image to the private Nexus registry.

---

## 🏗️ Architecture

The infrastructure consists of three dedicated AWS EC2 instances:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ Application Repository                                                   │
│                                                                         │
│ FastAPI RealWorld Application                                           │
│                                                                         │
│ CI/CD Pipeline                                                          │
│      │                                                                  │
│      │ Build Docker Image                                               │
│      ▼                                                                  │
│ Nexus Repository                                                        │
└───────────────────────┬─────────────────────────────────────────────────┘
                        │
                        │ Docker Image
                        ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #1 — fastapi-server                                                 │
│                                                                         │
│ • Pulls FastAPI Docker image from Nexus                                 │
│ • Runs FastAPI application                                             │
│ • Application metrics: port 8000                                       │
│ • Node Exporter: port 9100                                             │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                │ Metrics
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #3 — monitoring-server                                              │
│                                                                         │
│ Docker Compose monitoring stack                                         │
│                                                                         │
│ • Prometheus: 9090                                                     │
│ • Grafana: 3000                                                        │
│ • Alertmanager: 9093                                                   │
└─────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│ EC2 #2 — nexus-server                                                   │
│                                                                         │
│ • Sonatype Nexus Repository                                             │
│ • Private Docker Registry                                               │
│ • Ports: 8081–8083                                                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 End-to-End Deployment Flow

The application and infrastructure are separated into two repositories.

```text
┌──────────────────────────────┐
│  FastAPI Application Repo    │
│                              │
│  Application Code            │
│  Dockerfile                  │
│  CI/CD Pipeline              │
└──────────────┬───────────────┘
               │
               │ Build & Push
               ▼
┌──────────────────────────────┐
│      Nexus Repository        │
│                              │
│   Private Docker Registry    │
└──────────────┬───────────────┘
               │
               │ Pull Docker Image
               ▼
┌──────────────────────────────┐
│   Infrastructure Repo        │
│                              │
│ Terraform + Ansible          │
└──────────────┬───────────────┘
               │
               │ Ansible Deployment
               ▼
┌──────────────────────────────┐
│       EC2 #1                 │
│      FastAPI Server          │
│                              │
│   Docker Container           │
└──────────────┬───────────────┘
               │
               │ Metrics
               ▼
┌──────────────────────────────┐
│      EC2 #3                  │
│  Monitoring Server           │
│                              │
│ Prometheus                   │
│ Grafana                      │
│ Alertmanager                 │
└──────────────┬───────────────┘
               │
               ▼
             Slack
```

The **application repository** is responsible for building and publishing the application image.

This **infrastructure repository** is responsible for provisioning the AWS infrastructure, configuring the servers, retrieving the application image from Nexus, deploying it to EC2 #1, and configuring the observability stack.

The CI/CD implementation and application build process are documented separately in the application repository.

👉 **Application Repository:**
https://github.com/lukaradenkovic2003/fastapi-realworld-example-app

---

# 🛠️ Tech Stack

| Category                 | Technologies                   |
| ------------------------ | ------------------------------ |
| Application              | FastAPI                        |
| Cloud                    | AWS EC2                        |
| Infrastructure as Code   | Terraform                      |
| Configuration Management | Ansible                        |
| Containerization         | Docker, Docker Compose         |
| Container Registry       | Sonatype Nexus Repository      |
| Metrics Collection       | Prometheus                     |
| Visualization            | Grafana                        |
| System Monitoring        | Node Exporter                  |
| Alerting                 | Grafana Alerting, Alertmanager |
| Notifications            | Slack Webhooks                 |
| Automation               | Ansible Playbooks & Roles      |
| Scripting                | Python                         |

---

# 📁 Repository Structure

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
├── ansible.cfg
├── .gitignore
└── README.md
```

---

# ☁️ AWS Infrastructure

The infrastructure is divided into three EC2 instances, each with a dedicated responsibility.

## EC2 #1 — FastAPI Server

The application server runs the FastAPI Docker container retrieved from the private Nexus registry.

Services:

```text
FastAPI Application
Node Exporter
Docker
```

Ports:

```text
8000 → FastAPI
9100 → Node Exporter
```

The application exposes metrics that are collected by Prometheus.

---

## EC2 #2 — Nexus Server

The Nexus server provides the private Docker registry used to store application images.

Services:

```text
Sonatype Nexus Repository
Docker Registry
```

Ports:

```text
8081 → Nexus
8082 → Docker Registry
8083 → Docker Registry
```

The FastAPI application image is published to Nexus by the application repository's CI/CD pipeline.

The infrastructure deployment then retrieves the required image from Nexus and deploys it to EC2 #1.

---

## EC2 #3 — Monitoring Server

The monitoring server runs the complete observability stack using Docker Compose.

Services:

```text
Prometheus
Grafana
Alertmanager
```

Ports:

```text
9090 → Prometheus
3000 → Grafana
9093 → Alertmanager
```

---

# 🏗️ Infrastructure as Code

## Terraform

Terraform is responsible for provisioning the AWS infrastructure.

The Terraform layer provides the cloud infrastructure required by the application, registry, and monitoring stack.

The general workflow is:

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ├── EC2 #1 → FastAPI
    ├── EC2 #2 → Nexus
    └── EC2 #3 → Monitoring
```

Terraform and Ansible have deliberately separated responsibilities.

**Terraform** handles infrastructure provisioning.

**Ansible** handles server configuration and application/service deployment.

---

# ⚙️ Configuration Management

## Ansible

Ansible is responsible for configuring the EC2 instances and deploying the required services.

The project uses reusable Ansible roles:

```text
roles/
├── docker/
├── monitoring/
└── nexus/
```

Playbooks are separated according to infrastructure responsibility:

```text
app.yml
    │
    └── FastAPI + Node Exporter

nexus.yml
    │
    └── Nexus Repository

monitoring.yml
    │
    └── Prometheus + Grafana + Alertmanager
```

---

# 🐳 Application Deployment

The FastAPI application is maintained separately from the infrastructure repository.

The application repository contains the application source code, Dockerfile, and CI/CD pipeline responsible for building and publishing the Docker image.

### Application Repository

https://github.com/lukaradenkovic2003/fastapi-realworld-example-app

The infrastructure repository does not build the application image.

Instead, the deployment process retrieves the application image from Nexus and deploys it to **EC2 #1**.

```text
Application Repository
        │
        │ CI/CD
        ▼
Docker Image
        │
        │ Push
        ▼
Nexus Registry
        │
        │ Pull
        ▼
EC2 #1
        │
        ▼
FastAPI Container
```

The complete CI/CD implementation is documented in the application repository.

---

# 🚀 Deployment

## Prerequisites

The following tools are required:

* AWS account
* Terraform
* Ansible
* Docker
* WSL/Linux environment
* SSH private key
* Python 3

---

## 1. Provision AWS Infrastructure

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure plan:

```bash
terraform plan
```

Provision the infrastructure:

```bash
terraform apply
```

After provisioning, obtain the EC2 connection information required by Ansible.

---

## 2. Configure Ansible Inventory

Create the inventory from the provided example:

```bash
cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini
```

Configure the EC2 hosts and SSH connection variables in:

```text
ansible/inventory/hosts.ini
```

The local inventory should not be committed if it contains environment-specific or sensitive information.

---

## 3. Deploy Nexus

First configure the Nexus server:

```bash
cd ansible

ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/nexus.yml
```

This prepares EC2 #2 as the private Docker registry.

---

## 4. Deploy FastAPI Application

The application image must first be available in Nexus through the application repository's CI/CD pipeline.

The infrastructure deployment then retrieves the Docker image from Nexus and deploys it to EC2 #1.

Run:

```bash
ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/app.yml
```

This configures the application server and deploys:

* FastAPI Docker container
* Node Exporter
* Docker configuration

The deployment flow is:

```text
Nexus
  │
  │ Pull application image
  ▼
EC2 #1
  │
  ├── Docker
  │
  ├── FastAPI Container
  │
  └── Node Exporter
```

---

## 5. Deploy Monitoring Stack

Run:

```bash
ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.ini playbooks/monitoring.yml
```

The monitoring role deploys the Docker Compose stack containing:

```text
Prometheus
Grafana
Alertmanager
```

Configuration files are generated dynamically using Ansible/Jinja2 templates.

---

# 📊 Observability

The observability stack combines application metrics, infrastructure metrics, dashboards, and automated alerting.

## Prometheus

Prometheus collects metrics from:

* FastAPI
* Node Exporter

Default port:

```text
9090
```

Application-level metrics include:

```text
http_requests_total
```

---

## Grafana

Grafana provides dashboards and alerting for application and infrastructure metrics.

Default port:

```text
3000
```

The monitoring stack can visualize:

* HTTP request activity
* CPU usage
* Memory usage
* Disk usage
* Network metrics
* System load
* Application metrics
* Prometheus targets
* Alert states

---

## Node Exporter

Node Exporter exposes Linux host-level metrics to Prometheus.

Default port:

```text
9100
```

Metrics include:

* CPU
* Memory
* Disk
* Network
* System load

---

# 🚨 Alerting

The project includes automated alerting using Prometheus, Grafana, Alertmanager, and Slack.

The general workflow is:

```text
FastAPI / Node Exporter
          │
          │ Metrics
          ▼
      Prometheus
          │
          │ Alert condition
          ▼
       Grafana
          │
          │ Alert
          ▼
     Alertmanager
          │
          │ Webhook
          ▼
        Slack
```

---

## FastAPI High Request Rate

The monitoring stack includes a Grafana alert rule named:

```text
FastAPI-High-Request-Rate
```

The rule monitors:

```text
http_requests_total
```

and triggers when the configured request threshold is exceeded.

When the condition is met, the alert enters the:

```text
Firing
```

state.

### Alert Example

![FastAPI High Request Rate Alert](docs/images/fastapi-high-request-rate-alert.png)

This demonstrates the complete application observability workflow:

```text
Application Traffic
        │
        ▼
Application Metrics
        │
        ▼
Prometheus
        │
        ▼
Grafana Alert
        │
        ▼
Alertmanager
        │
        ▼
Slack
```

---

# 🔔 Alertmanager

Alertmanager handles alert routing and notification delivery.

The configuration is generated through the Ansible Jinja2 template:

```text
alertmanager.yml.j2
```

Default port:

```text
9093
```

Alertmanager is responsible for handling the notification stage after an alert has been triggered.

---

# 📱 Slack Notifications

Triggered alerts can be routed to Slack through Alertmanager.

Example:

```text
High Request Rate
       │
       ▼
   Prometheus
       │
       ▼
    Grafana
       │
       ▼
 Alertmanager
       │
       ▼
     Slack
```

This provides automated notification when monitored conditions require attention.

---

# 🧪 Load Testing

The repository includes a Python script for generating application traffic:

```text
load_test.py
```

Run:

```bash
python3 load_test.py
```

The generated traffic can be used to increase application request activity and observe the resulting metrics in Prometheus and Grafana.

It can also be used to demonstrate the `FastAPI-High-Request-Rate` alert.

---

# 🔐 Security Considerations

The project separates infrastructure configuration from environment-specific configuration and sensitive values.

Recommended practices include:

* Keep `hosts.ini` out of version control.
* Keep SSH private keys outside the repository.
* Do not commit Slack webhook URLs.
* Use environment variables or Ansible Vault for sensitive values.
* Restrict EC2 Security Group access to required ports.
* Avoid exposing monitoring interfaces publicly unless required.
* Use HTTPS and authentication when exposing services externally.

---

# 🔄 Infrastructure Workflow

The complete system can be summarized as:

```text
                   ┌────────────────────────┐
                   │  FastAPI Application   │
                   │        Repo            │
                   └───────────┬────────────┘
                               │
                               │ CI/CD
                               ▼
                   ┌────────────────────────┐
                   │   Nexus Docker Registry│
                   │        EC2 #2          │
                   └───────────┬────────────┘
                               │
                               │ Docker Pull
                               ▼
                   ┌────────────────────────┐
                   │    FastAPI Server      │
                   │        EC2 #1          │
                   │                        │
                   │ FastAPI + Node Exporter│
                   └───────────┬────────────┘
                               │
                               │ Metrics
                               ▼
                   ┌────────────────────────┐
                   │   Monitoring Server    │
                   │        EC2 #3          │
                   │                        │
                   │ Prometheus             │
                   │ Grafana                │
                   │ Alertmanager           │
                   └───────────┬────────────┘
                               │
                               │ Alerts
                               ▼
                            Slack
```

---

# 🎯 DevOps & SRE Concepts Demonstrated

This project demonstrates practical experience with:

* AWS EC2
* Infrastructure as Code
* Terraform
* Ansible
* Ansible Roles
* Docker
* Docker Compose
* Private Docker Registry
* Nexus Repository
* Application deployment
* Configuration management
* Prometheus
* Grafana
* Node Exporter
* Alertmanager
* Slack Webhooks
* Application metrics
* Infrastructure metrics
* Observability
* Alerting
* Load testing
* Python automation
* Separation of application and infrastructure repositories

---

# 📈 Architecture Summary

| Component     | Responsibility          |      Port |
| ------------- | ----------------------- | --------: |
| FastAPI       | Application             |      8000 |
| Node Exporter | EC2 system metrics      |      9100 |
| Nexus         | Private Docker Registry | 8081–8083 |
| Prometheus    | Metrics collection      |      9090 |
| Grafana       | Dashboards & alerting   |      3000 |
| Alertmanager  | Alert routing           |      9093 |

---

# 🔮 Possible Future Improvements

Potential extensions include:

* Automated deployment triggered by a new application image
* Terraform remote state using S3
* AWS IAM roles
* HTTPS with TLS certificates
* Cloudflare integration
* Centralized logging
* Loki integration with Grafana
* SLO/SLA-based alerting
* Infrastructure-as-code testing
* Automated rollback
* Blue/green or rolling deployments

---

# 📚 Related Repository

## FastAPI RealWorld Application

The application source code and CI/CD implementation are maintained separately:

https://github.com/lukaradenkovic2003/fastapi-realworld-example-app

The application repository documents how the FastAPI application is containerized and how its CI/CD pipeline publishes the Docker image to Nexus.

This infrastructure repository focuses on the **AWS infrastructure, configuration management, deployment, observability, and alerting layers**.

---

# 🎯 Project Purpose

The goal of this project is to demonstrate how a cloud-based application can be:

```text
Provisioned
     ↓
Configured
     ↓
Containerized
     ↓
Published to a Private Registry
     ↓
Deployed to AWS EC2
     ↓
Monitored
     ↓
Alerted
     ↓
Observed through Grafana
```

using modern DevOps and SRE tooling.

The project combines:

```text
AWS
+
Terraform
+
Ansible
+
Docker
+
FastAPI
+
Nexus
+
Prometheus
+
Grafana
+
Alertmanager
+
Slack
```


---



