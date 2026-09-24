variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "database_subnet_cidrs" { type = list(string) }

variable "instance_type" { type = string }
variable "eks_node_instance_type" { type = string }
variable "eks_desired_nodes" { type = number }
variable "eks_min_nodes" { type = number }
variable "eks_max_nodes" { type = number }

variable "key_name" { type = string }
variable "admin_cidr" {
  type        = string
  description = "Your public IPv4 address in CIDR format, for example 203.0.113.10/32. Do not use 0.0.0.0/0."
}

variable "jenkins_volume_size" { type = number, default = 40 }
variable "monitoring_volume_size" { type = number, default = 40 }

variable "rds_instance_class" { type = string, default = "db.t3.micro" }
variable "rds_engine" { type = string, default = "mariadb" }
variable "rds_engine_version" { type = string, default = "10.11" }
variable "rds_database_name" { type = string, default = "flightdb" }
variable "rds_username" { type = string, default = "admin" }
variable "rds_password" {
  type      = string
  sensitive = true
}
variable "rds_multi_az" { type = bool, default = false }
variable "rds_backup_retention_days" { type = number, default = 7 }

variable "s3_bucket_name" { type = string }
variable "s3_force_destroy" { type = bool, default = false }

variable "ecr_repositories" { type = list(string) }

variable "sns_topic_name" { type = string }
variable "alert_email" { type = string }

variable "cloudwatch_period" { type = number, default = 300 }
variable "ec2_cpu_threshold" { type = number, default = 80 }
variable "rds_cpu_threshold" { type = number, default = 80 }
variable "rds_free_storage_threshold_bytes" { type = number, default = 5368709120 }

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
