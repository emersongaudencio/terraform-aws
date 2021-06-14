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

echo 'resource "aws_security_group" "sg-prod-instance-mysql-57" {
  vpc_id      = var.VPC_ID
  name        = "allow-rds-mysql"
  description = "allow-rds-mysql"
  ingress {
    from_port       = 3306
    to_port         = 3306
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
    Name = "sg-prod-instance-mysql-57"
    Owner       = "DBA-Team"
    Environment = "prod"
  }
}
' > securitygroup.tf

echo 'resource "aws_db_parameter_group" "prod-instance-mysql-57" {
  name   = "prod-instance-mysql-57"
  family = "mysql5.7"

  # general configs
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "sql_mode"
    value = "ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  }

  parameter {
    name  = "optimizer_switch"
    value = "index_merge_intersection=off"
  }

  parameter {
    name  = "thread_cache_size"
    value = "1024"
  }

  # logbin configs
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_row_image"
    value = "MINIMAL"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  parameter {
    name  = "sync_binlog"
    value = "1"
  }

  # innodb vars
  parameter {
    name  = "innodb_flush_log_at_trx_commit"
    value = "1"
  }

  parameter {
    name  = "innodb_file_per_table"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_flush_method"
    value = "O_DIRECT"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_flush_neighbors"
    value = "0"
  }

  parameter {
    name  = "innodb_log_buffer_size"
    value = "16777216"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_lru_scan_depth"
    value = "4096"
  }

  parameter {
    name  = "innodb_purge_threads"
    value = "4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_sync_array_size"
    value = "4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_autoinc_lock_mode"
    value = "2"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_print_all_deadlocks"
    value = "1"
  }

  parameter {
    name  = "innodb_max_dirty_pages_pct"
    value = "90"
  }

  parameter {
    name  = "innodb_thread_concurrency"
    value = "0"
  }

  parameter {
    name  = "innodb_log_file_size"
    value = "1073741824"
    apply_method = "pending-reboot"
  }

  # table configs
  parameter {
    name  = "table_open_cache"
    value = "16384"
  }

  parameter {
    name  = "table_definition_cache"
    value = "52428"
  }

  parameter {
    name  = "max_heap_table_size"
    value = "16777216"
  }

  parameter {
    name  = "tmp_table_size"
    value = "16777216"
  }

  # connection configs
  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
  }

  parameter {
    name  = "max_connect_errors"
    value = "100"
  }

  parameter {
    name  = "wait_timeout"
    value = "28800"
  }

  parameter {
    name  = "connect_timeout"
    value = "60"
  }

  parameter {
    name  = "skip_name_resolve"
    value = "1"
    apply_method = "pending-reboot"
  }

  # sort and group configs
  parameter {
    name  = "key_buffer_size"
    value = "33554432"
  }

  parameter {
    name  = "sort_buffer_size"
    value = "134217728"
  }

  parameter {
    name  = "join_buffer_size"
    value = "134217728"
  }

  parameter {
    name  = "myisam_sort_buffer_size"
    value = "134217728"
  }

  parameter {
    name  = "innodb_sort_buffer_size"
    value = "67108864"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "read_rnd_buffer_size"
    value = "524288"
  }

  parameter {
    name  = "read_buffer_size"
    value = "262144"
  }

  parameter {
    name  = "max_sort_length"
    value = "262144"
  }

  parameter {
    name  = "max_length_for_sort_data"
    value = "262144"
  }

  parameter {
    name  = "group_concat_max_len"
    value = "2048"
  }

  # log configs
  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "0"
  }

  parameter {
    name  = "log_slow_admin_statements"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  # Enable scheduler on mysql
  parameter {
    name  = "event_scheduler"
    value = "ON"
    apply_method = "pending-reboot"
  }

  # Performance monitoring
  parameter {
    name  = "performance_schema"
    value = "1"
    apply_method = "pending-reboot"
  }

  #### MTS config ####
  parameter {
    name  = "slave_parallel_type"
    value = "LOGICAL_CLOCK"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "slave_parallel_workers"
    value = "8"
  }

  parameter {
    name  = "slave_preserve_commit_order"
    value = "1"
  }

  #### extra confs ####
  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }

  parameter {
    name  = "binlog_order_commits"
    value = "1"
  }

  parameter {
    name  = "enforce_gtid_consistency"
    value = "ON"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "session_track_gtids"
    value = "1"
  }

  parameter {
    name  = "relay_log_info_repository"
    value = "TABLE"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "gtid-mode"
    value = "ON_PERMISSIVE"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "prod-instance-mysql-57"
    Owner       = "DBA-Team"
    Environment = "prod"
  }
}
' > rds_mysql_parameter_group.tf

### apply changes to aws ###
terraform init
terraform apply -auto-approve
