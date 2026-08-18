resource "aws_security_group" "infra_sg" {
  name        = "realworld-infra-sg"
  description = "Security Group for FastAPI, Nexus, and Monitoring"
  vpc_id      = aws_vpc.main.id

  # SSH Access from anywhere (Required for management and Ansible)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FastAPI Web Application port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nexus UI and Docker HTTP Registry port range
  ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana Dashboard port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus and Alertmanager ports
  ingress {
    from_port   = 9090
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # INTERNAL COMMUNICATION (Allows instances sharing this SG to talk freely on any port)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }

  # Outbound internet traffic (Necessary to fetch Docker images and apt packages)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "realworld-infra-sg"
  }
}
