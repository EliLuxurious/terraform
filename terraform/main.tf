terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian official
  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }
}

resource "aws_security_group" "sg" {
  name        = "comportamiento-sg"
  description = "Permitir HTTP y SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "comportamiento" {
  ami                         = data.aws_ami.debian.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose-plugin git
    systemctl enable --now docker

    su - debian -c "git clone ${var.repo_url} ~/cloud_dev_api"

    cat > /home/debian/cloud_dev_api/comportamiento/docker-compose.yml << 'YAML'
    version: "3.9"
    services:
      comportamiento:
        build: .
        ports:
          - "8000:8000"
        environment:
          CLIMA_API_BASE: "http://${var.elia_public_host}:8001/clima"
          TEMBLOR_API_BASE: "http://${var.elia_public_host}:8002/temblor"
        restart: unless-stopped
    YAML

    su - debian -c "cd ~/cloud_dev_api/comportamiento && docker compose up -d --build"
  EOF

  tags = {
    Name = "comportamiento-instance"
  }
}
