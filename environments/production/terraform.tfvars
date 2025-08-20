# Production Environment Configuration

# Basic Configuration
aws_region       = "ap-northeast-2"
environment_name = "production"

# VPC Configuration
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnet_cidrs   = ["10.0.5.0/24", "10.0.6.0/24"]

# Security Configuration (프로덕션 보안 강화)
enable_ssh_access     = false
ssh_cidr_blocks       = []
enable_ecs_alb_access = false
enable_ecs_ssh        = false

# Compute Configuration (고성능)
instance_type               = "t3.small"
key_pair_name              = null
min_size                   = 2
max_size                   = 6
desired_capacity           = 3
enable_deletion_protection = true  # 삭제 보호

# Database Configuration (프로덕션 고가용성)
db_engine                   = "mysql"
db_engine_version          = "8.0.35"
db_instance_class          = "db.t3.medium"
db_allocated_storage       = 100
db_max_allocated_storage   = 500
db_name                    = "webapp_prod"
db_username                = "admin"
db_password                = "CHANGE_THIS_SECURE_PASSWORD!"  # 반드시 변경!
db_multi_az                = true   # Multi-AZ 배포
db_backup_retention_period = 30     # 30일 백업 보관
db_deletion_protection     = true   # 삭제 보호
db_skip_final_snapshot     = false  # 최종 스냅샷 생성

# S3 Storage Configuration (프로덕션)
grading_bucket_suffix       = "prod-files"
enable_s3_versioning       = true
enable_s3_lifecycle        = true
s3_lifecycle_expiration_days = 2555  # 7년 보관
enable_s3_metrics          = true
enable_s3_cors             = false   # 보안상 비활성화
s3_cors_allowed_origins    = []

# Amazon MQ Configuration (프로덕션 고가용성)
mq_engine_type         = "ActiveMQ"
mq_engine_version      = "5.17.6"
mq_instance_type       = "mq.t3.small"
mq_deployment_mode     = "ACTIVE_STANDBY_MULTI_AZ"  # 고가용성
mq_admin_username      = "admin"
mq_admin_password      = "CHANGE_THIS_MQ_PASSWORD!"  # 반드시 변경!
mq_enable_general_logs = true
mq_enable_audit_logs   = true   # 감사 로그 활성화
mq_log_retention_days  = 30     # 30일 로그 보관

# ECS Configuration (프로덕션 고성능)
grading_container_image = "YOUR_ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/grading-service:latest"
use_fargate            = true
ecs_task_cpu           = "1024"  # 1 vCPU
ecs_task_memory        = "2048"  # 2GB RAM
ecs_container_cpu      = 512
ecs_container_memory   = 1024
ecs_desired_count      = 3       # 고가용성을 위한 3개 인스턴스

# ECS Auto Scaling (프로덕션)
enable_ecs_autoscaling   = true
ecs_min_capacity        = 2
ecs_max_capacity        = 20     # 높은 확장성
ecs_cpu_target_value    = 60     # 낮은 임계값으로 빠른 확장
ecs_memory_target_value = 70

# Grading System Configuration
grading_queue_name        = "prod-grading-requests"
grading_result_queue_name = "prod-grading-results"

# Monitoring Configuration (프로덕션 모니터링 강화)
enable_container_insights = true
enable_ecs_monitoring    = true
