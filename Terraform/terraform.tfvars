# Copy this file to your working environment and REPLACE every CHANGE_ME value.
# This file is gitignored because it can contain secrets.

aws_region   = "ap-south-1"
project_name = "flight-reservation"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"
availability_zones = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]

instance_type            = "c7i-flex.large"
eks_node_instance_type   = "c7i-flex.large"
eks_desired_nodes        = 2
eks_min_nodes             = 2
eks_max_nodes             = 2

key_name   = "CHANGE_ME_EC2_KEYPAIR_NAME"
admin_cidr = "CHANGE_ME_YOUR_PUBLIC_IP/32"

jenkins_volume_size    = 40
monitoring_volume_size = 40

grafana_admin_password = "CHANGE_ME_GRAFANA_PASSWORD"

rds_instance_class       = "db.t3.micro"
rds_engine               = "mariadb"
rds_engine_version       = "10.11"
rds_database_name        = "flightdb"
rds_username             = "admin"
rds_password             = "CHANGE_ME_RDS_PASSWORD"
rds_multi_az             = false
rds_backup_retention_days = 7

s3_bucket_name = "flight-reservation-important-files-CHANGE_ME_UNIQUE"
s3_force_destroy = false

ecr_repositories = [
  "flight-reservation-app",
  "flight-checkin-app",
  "flight-frontend"
]

sns_topic_name = "flight-reservation-alerts"
alert_email    = "CHANGE_ME_EMAIL@example.com"

cloudwatch_period = 300
ec2_cpu_threshold = 80
rds_cpu_threshold = 80
rds_free_storage_threshold_bytes = 5368709120
