#!/bin/bash
### create aws config cred file ###
echo 'AWS_ACCESS_KEY:AAAAAAAAAAAAAAAAAAAA
AWS_SECRET_KEY:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' > .aws_cred

### initialize aws config ###
TF_VAR_AWS_ACCESS_KEY=$(cat .aws_cred | grep AWS_ACCESS_KEY | awk -F ":" {'print $2'})
TF_VAR_AWS_SECRET_KEY=$(cat .aws_cred | grep AWS_SECRET_KEY | awk -F ":" {'print $2'})
export $TF_VAR_AWS_ACCESS_KEY
export $TF_VAR_AWS_SECRET_KEY

echo 'terraform {
  required_version = ">= 0.12"
}' > version.tf

echo 'provider "aws" {
  region = var.AWS_REGION
}' > provider_aws.tf

echo 'variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "ansible"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "ansible.pub"
}

variable "DB_SUBNET_ID_AZA" {
  default = "subnet-0c5b53dee69f87d8b"
}

variable "DB_SUBNET_ID_AZB" {
  default = "subnet-001726fd4461296bf"
}

variable "DB_SUBNET_ID_AZC" {
  default = "subnet-0c85db3b2dc8e7a16"
}

variable "DB_INSTANCE_TYPE" {
  default = "m5.xlarge"
}

variable "PROXY_INSTANCE_TYPE" {
  default = "t3.xlarge"
}

variable "VPC_ID" {
  default = "vpc-054757ffa6143338b"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0affd4508a5d2481b"
    us-east-2 = "ami-01e36b7901e884a10"
    us-west-1 = "ami-098f55b4287a885ba"
    us-west-2 = "ami-0bc06212a56393ee1"
    eu-west-1 = "ami-0b850cf02cc00fdc8"
    eu-west-2 = "ami-09e5afc68eed60ef4"
    ap-southeast-1 = "ami-07f65177cb990d65b"
    ap-southeast-2 = "ami-0b2045146eb00b617"
  }
}' > vars.tf

echo 'resource "aws_security_group" "allow-ssh" {
  vpc_id      = var.VPC_ID
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_security_group" "allow-mariadb" {
  vpc_id      = var.VPC_ID
  name        = "allow-mariadb"
  description = "allow-mariadb"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  ingress {
    from_port       = 4567
    to_port         = 4567
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  ingress {
    from_port       = 4568
    to_port         = 4568
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  ingress {
    from_port       = 4444
    to_port         = 4444
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  ingress {
    from_port       = 33306
    to_port         = 33306
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  ingress {
    from_port       = 33307
    to_port         = 33307
    protocol        = "tcp"
    cidr_blocks = ["10.70.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "allow-mariadb"
  }
}
' > securitygroup.tf

echo 'resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}' > key.tf

terraform init
