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
  default = "us-east-2"
}' > vars.tf

echo 'module "vpc-prod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name = "vpc-prod"
  cidr = "10.70.0.0/16"

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = ["10.70.1.0/24", "10.70.2.0/24", "10.70.3.0/24"]
  public_subnets  = ["10.70.101.0/24", "10.70.102.0/24", "10.70.103.0/24"]
  database_subnets    = ["10.70.21.0/24", "10.70.22.0/24"]
  elasticache_subnets = ["10.70.31.0/24", "10.70.32.0/24"]
  redshift_subnets    = ["10.70.41.0/24", "10.70.42.0/24"]
  intra_subnets       = ["10.70.51.0/24", "10.70.52.0/24"]


  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_public_redshift = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

module "vpc-pre-prod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name = "vpc-pre-prod"
  cidr = "10.60.0.0/16"

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = ["10.60.1.0/24", "10.60.2.0/24", "10.60.3.0/24"]
  public_subnets  = ["10.60.101.0/24", "10.60.102.0/24", "10.60.103.0/24"]
  database_subnets    = ["10.60.21.0/24", "10.60.22.0/24"]
  elasticache_subnets = ["10.60.31.0/24", "10.60.32.0/24"]
  redshift_subnets    = ["10.60.41.0/24", "10.60.42.0/24"]
  intra_subnets       = ["10.60.51.0/24", "10.60.52.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_public_redshift = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "pre-prod"
  }
}

module "vpc-staging" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name = "vpc-staging"
  cidr = "10.50.0.0/16"

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
  public_subnets  = ["10.50.101.0/24", "10.50.102.0/24", "10.50.103.0/24"]
  database_subnets    = ["10.50.21.0/24", "10.50.22.0/24"]
  elasticache_subnets = ["10.50.31.0/24", "10.50.32.0/24"]
  redshift_subnets    = ["10.50.41.0/24", "10.50.42.0/24"]
  intra_subnets       = ["10.50.51.0/24", "10.50.52.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_public_redshift = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

module "vpc-dev" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name = "vpc-dev"
  cidr = "10.40.0.0/16"

  azs             = ["${var.AWS_REGION}a", "${var.AWS_REGION}b", "${var.AWS_REGION}c"]
  private_subnets = ["10.40.1.0/24", "10.40.2.0/24", "10.40.3.0/24"]
  public_subnets  = ["10.40.101.0/24", "10.40.102.0/24", "10.40.103.0/24"]
  database_subnets    = ["10.40.21.0/24", "10.40.22.0/24"]
  elasticache_subnets = ["10.40.31.0/24", "10.40.32.0/24"]
  redshift_subnets    = ["10.40.41.0/24", "10.40.42.0/24"]
  intra_subnets       = ["10.40.51.0/24", "10.40.52.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_public_redshift = false

  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
' > vpc.tf

### apply changes to aws ###
terraform init
terraform apply -auto-approve
