# Variables for 3-Tier Architecture with Async Grading System
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment_name" {
  description = "Environment name prefix"
  type        = string
  default     = "3tier"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

# Security Configuration
variable "enable_ssh_access" {
  description = "Enable SSH access to web servers"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "enable_ecs_alb_access" {
  description = "Enable ALB access to ECS tasks"
  type        = bool
  default     = false
}

variable "enable_ecs_ssh" {
  description = "Enable SSH access to ECS instances (EC2 mode only)"
  type        = bool
  default     = false
}

# Compute Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of the key pair for instances"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

# Database Configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0.35"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "webapp"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "password123!"
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS"
  type        = bool
  default     = true
}

# S3 Storage Configuration
variable "grading_bucket_suffix" {
  description = "Suffix for grading S3 bucket name"
  type        = string
  default     = "files"
}

variable "enable_s3_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_s3_lifecycle" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

variable "s3_lifecycle_expiration_days" {
  description = "Number of days after which S3 objects expire"
  type        = number
  default     = 365
}

variable "enable_s3_metrics" {
  description = "Enable CloudWatch metrics for S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_cors" {
  description = "Enable CORS configuration for S3 bucket"
  type        = bool
  default     = false
}

variable "s3_cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

# Amazon MQ Configuration
variable "mq_engine_type" {
  description = "MQ engine type (ActiveMQ or RabbitMQ)"
  type        = string
  default     = "ActiveMQ"
  
  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.mq_engine_type)
    error_message = "Engine type must be either ActiveMQ or RabbitMQ."
  }
}

variable "mq_engine_version" {
  description = "MQ engine version"
  type        = string
  default     = "5.17.6"
}

variable "mq_instance_type" {
  description = "MQ broker instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "mq_deployment_mode" {
  description = "MQ deployment mode"
  type        = string
  default     = "SINGLE_INSTANCE"
  
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ"], var.mq_deployment_mode)
    error_message = "Deployment mode must be either SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ."
  }
}

variable "mq_admin_username" {
  description = "MQ admin username"
  type        = string
  default     = "admin"
}

variable "mq_admin_password" {
  description = "MQ admin password"
  type        = string
  default     = "mqpassword123!"
  sensitive   = true
}

variable "mq_enable_general_logs" {
  description = "Enable MQ general logging"
  type        = bool
  default     = true
}

variable "mq_enable_audit_logs" {
  description = "Enable MQ audit logging"
  type        = bool
  default     = false
}

variable "mq_log_retention_days" {
  description = "MQ CloudWatch log retention in days"
  type        = number
  default     = 7
}

# ECS Configuration
variable "grading_container_image" {
  description = "Docker image for grading service"
  type        = string
  default     = "nginx:latest"  # Replace with actual grading service image
}

variable "use_fargate" {
  description = "Use Fargate instead of EC2 for ECS tasks"
  type        = bool
  default     = true
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "512"
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = string
  default     = "1024"
}

variable "ecs_container_cpu" {
  description = "CPU units for ECS container"
  type        = number
  default     = 256
}

variable "ecs_container_memory" {
  description = "Memory for ECS container in MB"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

# ECS Auto Scaling
variable "enable_ecs_autoscaling" {
  description = "Enable auto scaling for ECS service"
  type        = bool
  default     = true
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 10
}

variable "ecs_cpu_target_value" {
  description = "Target CPU utilization percentage for ECS"
  type        = number
  default     = 70
}

variable "ecs_memory_target_value" {
  description = "Target memory utilization percentage for ECS"
  type        = number
  default     = 80
}

# Grading System Configuration
variable "grading_queue_name" {
  description = "Name of the grading request queue"
  type        = string
  default     = "grading-requests"
}

variable "grading_result_queue_name" {
  description = "Name of the grading result queue"
  type        = string
  default     = "grading-results"
}

# Monitoring Configuration
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for ECS"
  type        = bool
  default     = true
}

variable "enable_ecs_monitoring" {
  description = "Enable CloudWatch monitoring and alarms for ECS"
  type        = bool
  default     = true
}
