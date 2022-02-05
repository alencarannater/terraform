terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA3NKNUO7SAS3PL6MN"
  secret_key = "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"
}

variable "aws_az" {
  type = string
  description = "Define a availability zone que sera utilizada"
}

variable "aws_instance" {
  type = string
  description = "Define a instance que sera utilizada"
}

variable "aws_ami" {
  type = string
  description = "Define a imagem que sera utilizada"
}

variable "aws_private_ip" {
  type = string
  description = "Define o ip privado"
}

resource "aws_vpc" "vpc_brq" {
cidr_block = "10.0.0.0/16"
tags = {
    Name = "VPC-Legal"
    }
}

resource "aws_internet_gateway" "gw_brq" {
  vpc_id = aws_vpc.vpc_brq.id

  tags = {
    Name = "Internet Gateway Legal"
  }
}

resource "aws_route_table" "rotas" {
  vpc_id = aws_vpc.vpc_brq.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.gw_brq.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw_brq.id
  }

  tags = {
    Name = "rotaslegal"
  }
}

resource "aws_subnet" "subrede_brq" {
  vpc_id     = aws_vpc.vpc_brq.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.aws_az

  tags = {
    Name = "SubredeLegal"
  }
}

resource "aws_route_table_association" "associacao" {
  subnet_id      = aws_subnet.subrede_brq.id
  route_table_id = aws_route_table.rotas.id
}

resource "aws_security_group" "firewall" {
  name        = "abrir_portas"
  description = "Abrir porta 22 (SSH), 443 (HTTPS) e 80 (HTTP)"
  vpc_id      = aws_vpc.vpc_brq.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "Firewall"
  }
}
