variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "availability_zones" {
  type        = list(string)
  description = "Two Availability Zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private application/EKS subnet CIDRs"
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "Private RDS subnet CIDRs"
}

variable "admin_cidr" {
  type        = string
  description = "Administrator public IPv4 CIDR, e.g. 203.0.113.10/32"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins and monitoring"
}

variable "jenkins_volume_size" {
  type    = number
  default = 40
}

variable "monitoring_volume_size" {
  type    = number
  default = 40
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.35"
}

variable "eks_node_instance_type" {
  type        = string
  description = "EKS worker node instance type"
}

variable "eks_desired_nodes" {
  type    = number
  default = 2
}

variable "eks_min_nodes" {
  type    = number
  default = 2
}

variable "eks_max_nodes" {
  type    = number
  default = 2
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_engine" {
  type    = string
  default = "mariadb"
}

variable "rds_engine_version" {
  type    = string
  default = "10.11"
}

variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_max_allocated_storage" {
  type    = number
  default = 100
}

variable "rds_database_name" {
  type    = string
  default = "flightdb"
}

variable "rds_username" {
  type    = string
  default = "flightadmin"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "RDS master password"
}

variable "rds_backup_retention_days" {
  type    = number
  default = 7
}

variable "rds_multi_az" {
  type    = bool
  default = false
}

variable "rds_deletion_protection" {
  type    = bool
  default = false
}

variable "s3_bucket_prefix" {
  type        = string
  description = "S3 bucket prefix; AWS will append a unique suffix"
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "ecr_repositories" {
  type = list(string)
}

variable "sns_topic_name" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "cloudwatch_period" {
  type    = number
  default = 300
}

variable "ec2_cpu_threshold" {
  type    = number
  default = 80
}

variable "rds_cpu_threshold" {
  type    = number
  default = 80
}

variable "rds_free_storage_threshold_bytes" {
  type    = number
  default = 5368709120
}
