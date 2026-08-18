# --- FastAPI Application Server ---
resource "aws_security_group" "fastapi_sg" {
  name        = "realworld-fastapi-sg"
  description = "Security Group for FastAPI application server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "FastAPI application port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Prometheus scraping /metrics and node-exporter"
    from_port        = 8000
    to_port          = 9100
    protocol         = "tcp"
    security_groups  = [aws_security_group.monitoring_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "realworld-fastapi-sg"
  }
}

# --- Nexus Repository Server ---
resource "aws_security_group" "nexus_sg" {
  name        = "realworld-nexus-sg"
  description = "Security Group for Nexus repository/Docker registry"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Nexus UI and Docker HTTP registry"
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "realworld-nexus-sg"
  }
}

# --- Monitoring Server (Prometheus, Grafana, Alertmanager) ---
resource "aws_security_group" "monitoring_sg" {
  name        = "realworld-monitoring-sg"
  description = "Security Group for Prometheus, Grafana, Alertmanager"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Grafana dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Prometheus and Alertmanager UI"
    from_port   = 9090
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "realworld-monitoring-sg"
  }
}