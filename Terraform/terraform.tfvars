aws_region  = "ap-south-1"
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

# Replace with your current public IPv4 address in /32 notation.
admin_cidr = "CHANGE_ME_PUBLIC_IP/32"

# Existing EC2 key pair in AWS.
key_name = "CHANGE_ME_KEYPAIR"

# VM1 and VM2
instance_type = "c7i-flex.large"
jenkins_volume_size = 40
monitoring_volume_size = 40

# EKS: exactly two nodes
# Set this to an EKS-supported Kubernetes version in your target region.
eks_cluster_version = "1.35"
eks_node_instance_type = "c7i-flex.large"
eks_desired_nodes = 2
eks_min_nodes = 2
eks_max_nodes = 2

# Private RDS MariaDB
rds_instance_class = "db.t3.micro"
rds_engine = "mariadb"
rds_engine_version = "10.11"
rds_allocated_storage = 20
rds_max_allocated_storage = 100
rds_database_name = "flightdb"
rds_username = "flightadmin"
rds_password = "CHANGE_ME_STRONG_RDS_PASSWORD"
rds_backup_retention_days = 7
rds_multi_az = false
rds_deletion_protection = false

# Private S3 object storage for important application files.
s3_bucket_prefix = "flight-reservation-dev-files-"
s3_force_destroy = false

# Amazon ECR repositories
# Jenkins pushes these images and EKS nodes pull them.
ecr_repositories = [
  "flight-reservation-dev-reservation",
  "flight-reservation-dev-checkin",
  "flight-reservation-dev-frontend"
]

# SNS notifications
sns_topic_name = "flight-reservation-dev-alerts"
alert_email = "CHANGE_ME_ALERT_EMAIL@example.com"

# CloudWatch
cloudwatch_period = 300
ec2_cpu_threshold = 80
rds_cpu_threshold = 80
rds_free_storage_threshold_bytes = 5368709120
