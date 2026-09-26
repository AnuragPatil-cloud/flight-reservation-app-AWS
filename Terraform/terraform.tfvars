aws_region   = "ap-south-1"
project_name = "flight-reservation"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

database_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

# Change this to your current public IP/32.
admin_cidr = "YOUR_PUBLIC_IP/32"

# Existing AWS EC2 key pair name.
key_name = "Projects_practice"

# VM1 and VM2
# 2 vCPU / 4 GiB C7i-flex.large according to AWS instance family sizing.
ec2_instance_type = "c7i-flex.large"
jenkins_volume_size    = 40
monitoring_volume_size = 40

# EKS - exactly 2 worker nodes
# Both nodes use c7i-flex.large.
eks_node_instance_type = "c7i-flex.large"
eks_desired_nodes      = 2
eks_min_nodes          = 2
eks_max_nodes           = 2

# RDS MariaDB
rds_instance_class        = "db.t3.micro"
rds_engine_version        = "10.11"
rds_database_name         = "flightdb"
rds_username              = "flightadmin"
rds_password              = "CHANGE_ME_STRONG_PASSWORD"
rds_backup_retention_days = 1

# S3 application file storage
s3_bucket_prefix = "flight-reservation-dev-files-"

# ECR
# Jenkins will push these three application images.
ecr_repositories = [
  "flight-reservation-dev-reservation",
  "flight-reservation-dev-checkin",
  "flight-reservation-dev-frontend"
]

# SNS / CloudWatch alerts
sns_topic_name = "flight-reservation-dev-alerts"
alert_email    = "anurag.patil.devops@gmail.com"

ec2_cpu_threshold = 80
rds_cpu_threshold = 80
rds_free_storage_threshold_bytes = 5368709120
