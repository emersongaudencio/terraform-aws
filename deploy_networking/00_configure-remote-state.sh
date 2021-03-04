#!/bin/bash

# backend remote state
echo 'terraform {
  backend "s3" {
    bucket = "terraform-state-turbo-dba-prod"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
' > backend.tf
