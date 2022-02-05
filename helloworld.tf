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

resource "aws_network_interface" "interface_rede" {
  subnet_id       = aws_subnet.subrede_brq.id
  private_ips     = [var.aws_private_ip]
  security_groups = [aws_security_group.firewall.id]
  tags = {
    Name = "interfaceRede"
  }
}
resource "aws_eip" "ip_publico" {
  vpc                       = true
  network_interface         = aws_network_interface.interface_rede.id
  associate_with_private_ip = var.aws_private_ip
  depends_on                = [aws_internet_gateway.gw_brq]
}

output "printar_ip_publico" {
  value = aws_eip.ip_publico.public_ip
}

resource "aws_instance" "app_web" {
  ami               = var.aws_ami
  instance_type     = var.aws_instance
  availability_zone = var.aws_az
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.interface_rede.id
  }
  user_data = <<-EOF
               #! /bin/bash
               sudo apt-get update -y
               sudo apt-get install -y apache2
               sudo systemctl start apache2
               sudo systemctl enable apache2
               sudo bash -c 'echo "<h1>Essa mensagem que deu sucesso o processo</h1>"  > /var/www/html/index.html'
             EOF
  tags = {
    Name = "InstanciaLegal"
  }
}