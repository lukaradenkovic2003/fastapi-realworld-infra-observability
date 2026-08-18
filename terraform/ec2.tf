data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}


locals {
  instances = {
    fastapi = {
      name          = "fastapi-server"
      instance_type = "t3.micro"
      sg_id         = aws_security_group.fastapi_sg.id
    }
    nexus = {
      name          = "nexus-server"
      instance_type = "t3.small"
      sg_id         = aws_security_group.nexus_sg.id
    }
    monitoring = {
      name          = "monitoring-server"
      instance_type = "t3.small"
      sg_id         = aws_security_group.monitoring_sg.id
    }
  }
}

resource "aws_instance" "web" {
  for_each = local.instances

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [each.value.sg_id]
  key_name               = var.ssh_key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = each.value.name
    Role = each.key
  }
}