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
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
  }
}' > version.tf

echo 'provider "aws" {
  region = var.AWS_REGION
}' > provider_aws.tf

echo 'variable "AWS_REGION" {
  default = "us-east-1"
}

variable "VPC_ID" {
  default = "vpc-054757ffa6143338b"
}

variable "VPC_CIDR_BLOCKS" {
  default = "10.70.0.0/16"
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
  default = "db.t3.large"
}

locals {
  tags = {
    Owner       = "DBA-Team"
    Environment = "prod"
  }
}
' > vars.tf

echo 'resource "aws_security_group" "sg-prod-instance-pg-11" {
  vpc_id      = var.VPC_ID
  name        = "sg-prod-instance-pg-11"
  description = "sg-prod-instance-pg-11"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = [var.VPC_CIDR_BLOCKS]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "sg-prod-instance-pg-11"
    Owner       = "DBA-Team"
    Environment = "prod"
  }
}
' > securitygroup.tf

echo 'resource "aws_db_parameter_group" "prod-instance-pg-11" {
  name   = "prod-instance-pg-11"
  family = "postgres11"

  # general configs
  parameter {
    name  = "autovacuum"
    value = "1"
  }

  parameter {
    name  = "client_encoding"
    value = "utf8"
  }

  parameter {
    name  = "min_wal_size"
    value = "2048"
  }

  parameter {
    name  = "max_wal_size"
    value = "4096"
  }

  parameter {
    name  = "max_worker_processes"
    value = "8"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "checkpoint_completion_target"
    value = "0.9"
  }

  parameter {
    name  = "default_statistics_target"
    value = "100"
  }

  parameter {
    name  = "random_page_cost"
    value = "1.1"
  }

  parameter {
    name  = "effective_io_concurrency"
    value = "200"
  }

  parameter {
    name  = "work_mem"
    value = "16384"
  }

  # Logging configuration for pgbadger
  # logging_collector = on

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_checkpoints"
    value = "1"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_temp_files"
    value = "0"
  }

  parameter {
    name  = "lc_messages"
    value = "C"
  }

  parameter {
    name  = "log_filename"
    value = "postgresql.log.%Y-%m-%d-%H"
  }

  parameter {
    name  = "log_destination"
    value = "stderr"
  }

  parameter {
    name  = "wal_buffers"
    value = "16384"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "prod-instance-pg-11"
    Owner       = "DBA-Team"
    Environment = "prod"
  }
}
' > rds_postgres11_parameter_group.tf

### apply changes to aws ###
terraform init
terraform apply -auto-approve
