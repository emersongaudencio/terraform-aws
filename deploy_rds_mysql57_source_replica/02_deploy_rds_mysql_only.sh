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
# Source DB
################################################################################
# https://github.com/terraform-aws-modules/terraform-aws-rds/tree/master/examples/replica-mysql

module "source01" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.1.0"

  identifier = "mysql-57-prod-source01"

  # Disable creation of parameter group - provide a parameter group or default to AWS default
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "5.7.33"
  major_engine_version = "5.7"      # DB option group
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
  vpc_security_group_ids = [aws_security_group.sg-prod-instance-mysql-57.id]

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
  monitoring_role_name = "RDSMySQL57MonitoringRoleSource01"

  parameter_group_name   = "mysql-57-prod-source01" # must already exist in AWS

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
' > rds_mysql_source01.tf

echo '################################################################################
# Replica DB
################################################################################
# https://github.com/terraform-aws-modules/terraform-aws-rds/tree/master/examples/replica-mysql

module "replica01" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.1.0"

  identifier = "mysql-57-prod-replica01"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = module.source01.db_instance_id

  # Disable creation of parameter group - provide a parameter group or default to AWS default
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "5.7.33"
  major_engine_version = "5.7"      # DB option group
  instance_class       = var.DB_INSTANCE_TYPE

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # Username and password should not be set for replicas
  username = null
  password = null
  port     = 3306

  multi_az               = true
  subnet_ids             = [var.DB_SUBNET_ID_AZA, var.DB_SUBNET_ID_AZB]
  vpc_security_group_ids = [aws_security_group.sg-prod-instance-mysql-57.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general","slowquery","error"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you dont want to create it automatically
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name = "RDSMySQL57MonitoringRoleRepl01"

  parameter_group_name   = "mysql-57-prod-replica01" # must already exist in AWS

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
' > rds_mysql_replica01.tf

echo 'output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.source01.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.source01.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.source01.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.source01.db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.source01.db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.source01.db_instance_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.source01.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.source01.db_instance_status
}

output "db_instance_name" {
  description = "The database name"
  value       = module.source01.db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.source01.db_instance_username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesnt track it after initial creation)"
  value       = module.source01.db_instance_password
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.source01.db_instance_port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.source01.db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.source01.db_subnet_group_arn
}

output "db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = module.source01.enhanced_monitoring_iam_role_arn
}
' > output_rds_mysql_source01.tf

echo 'output "replica01_db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.replica01.db_instance_address
}

output "replica01_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.replica01.db_instance_arn
}

output "replica01_db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.replica01.db_instance_availability_zone
}

output "replica01_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.replica01.db_instance_endpoint
}

output "replica01_db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = module.replica01.db_instance_hosted_zone_id
}

output "replica01_db_instance_id" {
  description = "The RDS instance ID"
  value       = module.replica01.db_instance_id
}

output "replica01_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = module.replica01.db_instance_resource_id
}

output "replica01_db_instance_status" {
  description = "The RDS instance status"
  value       = module.replica01.db_instance_status
}

output "replica01_db_instance_name" {
  description = "The database name"
  value       = module.replica01.db_instance_name
}

output "replica01_db_instance_username" {
  description = "The master username for the database"
  value       = module.replica01.db_instance_username
  sensitive   = true
}

output "replica01_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesnt track it after initial creation)"
  value       = module.replica01.db_instance_password
  sensitive   = true
}

output "replica01_db_instance_port" {
  description = "The database port"
  value       = module.replica01.db_instance_port
}

output "replica01_db_subnet_group_id" {
  description = "The db subnet group name"
  value       = module.replica01.db_subnet_group_id
}

output "replica01_db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = module.replica01.db_subnet_group_arn
}

output "replica01_db_enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the monitoring role"
  value       = module.replica01.enhanced_monitoring_iam_role_arn
}
' > output_rds_mysql_replica01.tf

### apply changes to aws ###
terraform apply -auto-approve
