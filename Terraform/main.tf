module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  admin_cidr            = var.admin_cidr
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  eks_cluster_name = "${var.project_name}-${var.environment}-eks"
}

module "jenkins" {
  source = "./modules/ec2-jenkins"

  project_name       = var.project_name
  environment        = var.environment
  instance_type      = var.instance_type
  key_name           = var.key_name
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_id  = module.vpc.jenkins_security_group_id
  volume_size        = var.jenkins_volume_size
  iam_instance_profile = module.iam.jenkins_instance_profile_name
}

module "monitoring" {
  source = "./modules/ec2-monitoring"

  project_name       = var.project_name
  environment        = var.environment
  instance_type      = var.instance_type
  key_name           = var.key_name
  subnet_id          = module.vpc.public_subnet_ids[1]
  security_group_id  = module.vpc.monitoring_security_group_id
  volume_size        = var.monitoring_volume_size
  iam_instance_profile = module.iam.monitoring_instance_profile_name
  grafana_admin_password = var.grafana_admin_password
}

module "eks" {
  source = "./modules/eks"
  depends_on = [module.iam]

  project_name           = var.project_name
  environment            = var.environment
  cluster_name           = "${var.project_name}-${var.environment}-eks"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  node_instance_type     = var.eks_node_instance_type
  desired_nodes          = var.eks_desired_nodes
  min_nodes              = var.eks_min_nodes
  max_nodes              = var.eks_max_nodes
  eks_cluster_role_arn   = module.iam.eks_cluster_role_arn
  eks_node_role_arn      = module.iam.eks_node_role_arn
  monitoring_role_arn    = module.iam.monitoring_instance_role_arn
  node_security_group_id  = module.vpc.eks_node_security_group_id
}

module "rds" {
  source = "./modules/rds"

  project_name             = var.project_name
  environment              = var.environment
  subnet_ids               = module.vpc.database_subnet_ids
  security_group_id        = module.vpc.rds_security_group_id
  instance_class            = var.rds_instance_class
  engine                    = var.rds_engine
  engine_version            = var.rds_engine_version
  database_name             = var.rds_database_name
  username                  = var.rds_username
  password                  = var.rds_password
  multi_az                  = var.rds_multi_az
  backup_retention_days     = var.rds_backup_retention_days
}

module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  force_destroy = var.s3_force_destroy
  eks_node_role_name = module.iam.eks_node_role_name
}

module "ecr" {
  source = "./modules/ecr"

  repositories = var.ecr_repositories
}

module "sns" {
  source = "./modules/sns"

  topic_name  = var.sns_topic_name
  alert_email = var.alert_email
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name                = var.project_name
  environment                 = var.environment
  jenkins_instance_id         = module.jenkins.instance_id
  monitoring_instance_id      = module.monitoring.instance_id
  rds_instance_id             = module.rds.instance_id
  sns_topic_arn               = module.sns.topic_arn
  period                      = var.cloudwatch_period
  ec2_cpu_threshold           = var.ec2_cpu_threshold
  rds_cpu_threshold           = var.rds_cpu_threshold
  rds_free_storage_threshold  = var.rds_free_storage_threshold_bytes
}
