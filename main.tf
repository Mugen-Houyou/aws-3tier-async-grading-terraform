# 3-Tier Web Service Architecture with Terraform Modules + Async Grading System
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-name"
    values = ["${var.aws_region}a", "${var.aws_region}d"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  common_tags = {
    Environment = var.environment_name
    Project     = "3-tier-architecture-with-grading"
    ManagedBy   = "terraform"
  }
  
  aws_account_id = data.aws_caller_identity.current.account_id
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment_name        = var.environment_name
  vpc_cidr               = var.vpc_cidr
  availability_zones     = data.aws_availability_zones.available.names
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  database_subnet_cidrs  = var.database_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  environment_name      = var.environment_name
  vpc_id               = module.vpc.vpc_id
  enable_ssh_access    = var.enable_ssh_access
  ssh_cidr_blocks      = var.ssh_cidr_blocks
  enable_ecs_alb_access = var.enable_ecs_alb_access
  enable_ecs_ssh       = var.enable_ecs_ssh
}

# Storage Module (S3 for grading files)
module "storage" {
  source = "./modules/storage"

  environment_name           = var.environment_name
  bucket_suffix             = var.grading_bucket_suffix
  enable_versioning         = var.enable_s3_versioning
  enable_lifecycle          = var.enable_s3_lifecycle
  lifecycle_expiration_days = var.s3_lifecycle_expiration_days
  enable_metrics           = var.enable_s3_metrics
  enable_cors              = var.enable_s3_cors
  cors_allowed_origins     = var.s3_cors_allowed_origins
  tags                     = local.common_tags
}

# Messaging Module (Amazon MQ)
module "messaging" {
  source = "./modules/messaging"

  environment_name           = var.environment_name
  subnet_ids                = module.vpc.private_subnet_ids
  mq_security_group_id      = module.security_groups.mq_security_group_id
  
  engine_type               = var.mq_engine_type
  engine_version            = var.mq_engine_version
  host_instance_type        = var.mq_instance_type
  deployment_mode           = var.mq_deployment_mode
  
  admin_username            = var.mq_admin_username
  admin_password            = var.mq_admin_password
  
  enable_general_logs       = var.mq_enable_general_logs
  enable_audit_logs         = var.mq_enable_audit_logs
  log_retention_days        = var.mq_log_retention_days
  
  tags                      = local.common_tags
}

# ECS Grading Module
module "ecs_grading" {
  source = "./modules/ecs-grading"

  environment_name          = var.environment_name
  aws_region               = var.aws_region
  aws_account_id           = local.aws_account_id
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  ecs_security_group_id    = module.security_groups.ecs_security_group_id
  
  # Container Configuration
  grading_image            = var.grading_container_image
  use_fargate              = var.use_fargate
  task_cpu                 = var.ecs_task_cpu
  task_memory              = var.ecs_task_memory
  container_cpu            = var.ecs_container_cpu
  container_memory         = var.ecs_container_memory
  
  # Service Configuration
  desired_count            = var.ecs_desired_count
  
  # Auto Scaling
  enable_autoscaling       = var.enable_ecs_autoscaling
  min_capacity             = var.ecs_min_capacity
  max_capacity             = var.ecs_max_capacity
  cpu_target_value         = var.ecs_cpu_target_value
  memory_target_value      = var.ecs_memory_target_value
  
  # MQ Configuration
  mq_endpoint_parameter    = module.messaging.ssm_parameter_endpoint
  mq_username_parameter    = module.messaging.ssm_parameter_username
  mq_password_parameter    = module.messaging.ssm_parameter_password
  queue_name               = var.grading_queue_name
  result_queue_name        = var.grading_result_queue_name
  
  # S3 Configuration
  grading_bucket_name      = module.storage.bucket_id
  grading_bucket_arn       = module.storage.bucket_arn
  
  # Monitoring
  enable_container_insights = var.enable_container_insights
  enable_monitoring        = var.enable_ecs_monitoring
  
  tags                     = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  environment_name              = var.environment_name
  aws_region                   = var.aws_region
  vpc_id                       = module.vpc.vpc_id
  public_subnet_ids            = module.vpc.public_subnet_ids
  private_subnet_ids           = module.vpc.private_subnet_ids
  alb_security_group_id        = module.security_groups.alb_security_group_id
  web_server_security_group_id = module.security_groups.web_server_security_group_id
  
  ami_id                       = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_pair_name               = var.key_pair_name
  min_size                    = var.min_size
  max_size                    = var.max_size
  desired_capacity            = var.desired_capacity
  
  enable_deletion_protection  = var.enable_deletion_protection
  tags                        = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  environment_name             = var.environment_name
  database_subnet_ids          = module.vpc.database_subnet_ids
  database_security_group_id   = module.security_groups.database_security_group_id
  
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  allocated_storage           = var.db_allocated_storage
  max_allocated_storage       = var.db_max_allocated_storage
  
  database_name               = var.db_name
  username                    = var.db_username
  password                    = var.db_password
  
  multi_az                    = var.db_multi_az
  backup_retention_period     = var.db_backup_retention_period
  deletion_protection         = var.db_deletion_protection
  skip_final_snapshot         = var.db_skip_final_snapshot
  
  tags                        = local.common_tags
}
