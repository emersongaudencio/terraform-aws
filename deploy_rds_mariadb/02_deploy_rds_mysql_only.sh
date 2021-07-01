#!/bin/bash
### create aws config cred file ###
echo 'AWS_ACCESS_KEY:AAAAAAAAAAAAAAAAAAAA
AWS_SECRET_KEY:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' > .aws_cred

### initialize aws config ###
TF_VAR_AWS_ACCESS_KEY=$(cat .aws_cred | grep AWS_ACCESS_KEY | awk -F ":" {'print $2'})
TF_VAR_AWS_SECRET_KEY=$(cat .aws_cred | grep AWS_SECRET_KEY | awk -F ":" {'print $2'})
export $TF_VAR_AWS_ACCESS_KEY
export $TF_VAR_AWS_SECRET_KEY

echo '################################################################################
# RDS Module
################################################################################

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.1.0"

  identifier = "db-prod-mariadb103"

  # Disable creation of parameter group - provide a parameter group or default to AWS default
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MariaDB.Parameters.html
  engine               = "mariadb"
  engine_version       = "10.3.28"   # MariaDB version 10.3.20-28/10.4.13-18/10.5.8-9
  major_engine_version = "10.3"      # DB option group
  instance_class       = var.DB_INSTANCE_TYPE

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  name     = "dbadmin"
  username = "dbadmin"
  password = "YourPwdShouldBeLongAndSecure!"
  port     = 3306

  multi_az               = true
  subnet_ids             = [var.DB_SUBNET_ID_AZA, var.DB_SUBNET_ID_AZB]
  vpc_security_group_ids = [aws_security_group.sg-prod-instance-mariadb.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general","slowquery","error"]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you dont want to create it automatically
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name = "RDSMariaDB103MonitoringRole"

  parameter_group_name   = "prod-instance-mariadb103" # must already exist in AWS

  tags = local.tags
  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}
' > rds_mariadb.tf

echo 'output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.rds.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.rds.db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.rds.db_instance_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.rds.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.rds.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesnt track it after initial creation)"
  value       = module.rds.db_instance_password
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds.db_instance_port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.rds.db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.rds.db_subnet_group_arn
}

output "db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = module.rds.enhanced_monitoring_iam_role_arn
}
' > output_rds_mariadb.tf

### apply changes to aws ###
terraform apply -auto-approve
