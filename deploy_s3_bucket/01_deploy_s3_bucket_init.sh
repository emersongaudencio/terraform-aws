#!/bin/bash
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
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
  default = "us-east-2"
}' > vars.tf

echo 'module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }

}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-for-logs"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
}
' > s3_buckets.tf

#echo '# Output the VPC ids
#' > output_vpc.tf

### apply changes to aws ###
terraform init
terraform apply -auto-approve
