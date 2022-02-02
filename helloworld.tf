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

resource "aws_instance" "hello-world" {
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    tags = {Name = "VM-Numero1"}
  
}

resource "aws_vpc" "vpc_brq" {
cidr_block = "10.0.0.0/16"
tags = {
    Name = "VPC-Legal"
    }
}

resource "aws_subnet" "subrede_brq" {
  vpc_id     = aws_vpc.vpc_brq.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subrede Legal"
  }
}