# Staging Environment Configuration

# Basic Configuration
aws_region       = "ap-northeast-2"
environment_name = "staging"

# VPC Configuration
vpc_cidr                = "10.1.0.0/16"  # 다른 CIDR로 분리
public_subnet_cidrs     = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs    = ["10.1.3.0/24", "10.1.4.0/24"]
database_subnet_cidrs   = ["10.1.5.0/24", "10.1.6.0/24"]

# Security Configuration (스테이징 - 제한적 접근)
enable_ssh_access     = false
ssh_cidr_blocks       = ["10.1.0.0/16"]  # VPC 내부에서만
enable_ecs_alb_access = false
enable_ecs_ssh        = false

# Compute Configuration (프로덕션과 유사하지만 축소)
instance_type               = "t3.micro"
key_pair_name              = null
min_size                   = 2
max_size                   = 4
desired_capacity           = 2
enable_deletion_protection = false

# Database Configuration (스테이징용)
db_engine                   = "mysql"
db_engine_version          = "8.0.35"
db_instance_class          = "db.t3.small"
db_allocated_storage       = 50
db_max_allocated_storage   = 200
db_name                    = "webapp_staging"
db_username                = "admin"
db_password                = "stagingpassword123!"  # 스테이징용 비밀번호
db_multi_az                = false  # 비용 절약
db_backup_retention_period = 7      # 7일 백업
db_deletion_protection     = false
db_skip_final_snapshot     = true

# S3 Storage Configuration (스테이징용)
grading_bucket_suffix       = "staging-files"
enable_s3_versioning       = true
enable_s3_lifecycle        = true
s3_lifecycle_expiration_days = 90   # 3개월 보관
enable_s3_metrics          = true
enable_s3_cors             = false
s3_cors_allowed_origins    = []

# Amazon MQ Configuration (스테이징용)
mq_engine_type         = "ActiveMQ"
mq_engine_version      = "5.17.6"
mq_instance_type       = "mq.t3.micro"
mq_deployment_mode     = "SINGLE_INSTANCE"  # 비용 절약
mq_admin_username      = "admin"
mq_admin_password      = "mqstagingpassword123!"  # 스테이징용 비밀번호
mq_enable_general_logs = true
mq_enable_audit_logs   = false  # 비용 절약
mq_log_retention_days  = 7      # 7일 로그 보관

# ECS Configuration (스테이징용)
grading_container_image = "YOUR_ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/grading-service:staging"
use_fargate            = true
ecs_task_cpu           = "512"   # 중간 사양
ecs_task_memory        = "1024"  # 중간 사양
ecs_container_cpu      = 256
ecs_container_memory   = 512
ecs_desired_count      = 2       # 2개 인스턴스

# ECS Auto Scaling (스테이징용)
enable_ecs_autoscaling   = true
ecs_min_capacity        = 1
ecs_max_capacity        = 8      # 제한된 확장
ecs_cpu_target_value    = 70
ecs_memory_target_value = 75

# Grading System Configuration
grading_queue_name        = "staging-grading-requests"
grading_result_queue_name = "staging-grading-results"

# Monitoring Configuration (스테이징용)
enable_container_insights = true
enable_ecs_monitoring    = true
