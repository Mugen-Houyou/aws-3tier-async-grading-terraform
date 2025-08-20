# Development Environment Configuration

# Basic Configuration
aws_region       = "ap-northeast-2"
environment_name = "dev"

# VPC Configuration
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24"]

# Security Configuration (개발 환경용 - 보안 완화)
enable_ssh_access     = true
ssh_cidr_blocks       = ["0.0.0.0/0"]  # 개발 환경에서만!
enable_ecs_alb_access = true
enable_ecs_ssh        = false

# Compute Configuration (비용 최적화)
instance_type               = "t3.micro"
key_pair_name              = null  # SSH 키 페어 이름 설정 필요
min_size                   = 1
max_size                   = 2
desired_capacity           = 1
enable_deletion_protection = false

# Database Configuration (개발용 최소 사양)
db_engine                   = "mysql"
db_engine_version          = "8.0.35"
db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
db_max_allocated_storage   = 50
db_name                    = "webapp_dev"
db_username                = "admin"
db_password                = "devpassword123!"  # 개발용 비밀번호
db_multi_az                = false
db_backup_retention_period = 1  # 최소 백업
db_deletion_protection     = false
db_skip_final_snapshot     = true

# S3 Storage Configuration (개발용)
grading_bucket_suffix       = "dev-files"
enable_s3_versioning       = false  # 비용 절약
enable_s3_lifecycle        = false  # 비용 절약
s3_lifecycle_expiration_days = 30   # 짧은 보관 기간
enable_s3_metrics          = false  # 비용 절약
enable_s3_cors             = true   # 개발용 CORS 허용
s3_cors_allowed_origins    = ["*"]

# Amazon MQ Configuration (개발용 최소 사양)
mq_engine_type         = "ActiveMQ"
mq_engine_version      = "5.17.6"
mq_instance_type       = "mq.t3.micro"
mq_deployment_mode     = "SINGLE_INSTANCE"
mq_admin_username      = "admin"
mq_admin_password      = "mqdevpassword123!"  # 개발용 비밀번호
mq_enable_general_logs = true
mq_enable_audit_logs   = false  # 비용 절약
mq_log_retention_days  = 3      # 짧은 로그 보관

# ECS Configuration (개발용 최소 사양)
grading_container_image = "nginx:latest"  # 개발용 임시 이미지
use_fargate            = true
ecs_task_cpu           = "256"   # 최소 CPU
ecs_task_memory        = "512"   # 최소 메모리
ecs_container_cpu      = 128
ecs_container_memory   = 256
ecs_desired_count      = 1       # 최소 인스턴스

# ECS Auto Scaling (개발용)
enable_ecs_autoscaling   = true
ecs_min_capacity        = 1
ecs_max_capacity        = 3      # 제한된 확장
ecs_cpu_target_value    = 80     # 높은 임계값
ecs_memory_target_value = 85

# Grading System Configuration
grading_queue_name        = "dev-grading-requests"
grading_result_queue_name = "dev-grading-results"

# Monitoring Configuration (개발용 최소화)
enable_container_insights = false  # 비용 절약
enable_ecs_monitoring    = false   # 비용 절약
