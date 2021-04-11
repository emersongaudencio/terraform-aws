#!/bin/bash
# https://www.terraform.io/docs/language/settings/backends/s3.html
# backend remote state
echo 'terraform {
  backend "s3" {
    bucket = "terraform-state-turbo-dba-prod"
    key    = "psmysql-source-replica/terraform.tfstate"
    region = "us-east-1"
  }
}
' > backend.tf
