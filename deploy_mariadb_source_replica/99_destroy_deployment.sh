#!/bin/bash
### initialize aws config ###
TF_VAR_AWS_ACCESS_KEY=$(cat .aws_cred | grep AWS_ACCESS_KEY | awk -F ":" {'print $2'})
TF_VAR_AWS_SECRET_KEY=$(cat .aws_cred | grep AWS_SECRET_KEY | awk -F ":" {'print $2'})
export $TF_VAR_AWS_ACCESS_KEY
export $TF_VAR_AWS_SECRET_KEY

terraform plan -destroy -out=terraform.tfplan
terraform apply terraform.tfplan

# remove old files from initial deployment
rm -rf terraform.tfplan terraform.tfstate terraform.tfstate.backup
rm -rf *.tf
rm -rf *.txt
rm -rf ".terraform"
rm -rf ".aws_cred"
rm -rf ansible-mariadb-galera-cluster
rm -rf output
