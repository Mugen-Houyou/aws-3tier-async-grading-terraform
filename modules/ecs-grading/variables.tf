variable "environment_name" {
  description = "Environment name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# Container Configuration
variable "grading_image" {
  description = "Docker image for grading service"
  type        = string
  default     = "nginx:latest"  # Replace with actual grading service image
}

variable "use_fargate" {
  description = "Use Fargate instead of EC2 for ECS tasks"
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "CPU units for the task (Fargate: 256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "1024"
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

# Service Configuration
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "max_capacity_percent" {
  description = "Maximum capacity during deployment"
  type        = number
  default     = 200
}

variable "min_capacity_percent" {
  description = "Minimum capacity during deployment"
  type        = number
  default     = 50
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable auto scaling for ECS service"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage"
  type        = number
  default     = 80
}

variable "enable_memory_scaling" {
  description = "Enable memory-based auto scaling"
  type        = bool
  default     = true
}

variable "scale_in_cooldown" {
  description = "Scale in cooldown period in seconds"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Scale out cooldown period in seconds"
  type        = number
  default     = 300
}

# MQ Configuration
variable "mq_endpoint_parameter" {
  description = "SSM parameter name for MQ endpoint"
  type        = string
}

variable "mq_username_parameter" {
  description = "SSM parameter name for MQ username"
  type        = string
}

variable "mq_password_parameter" {
  description = "SSM parameter name for MQ password"
  type        = string
}

variable "queue_name" {
  description = "Name of the grading queue"
  type        = string
  default     = "grading-requests"
}

variable "result_queue_name" {
  description = "Name of the result queue"
  type        = string
  default     = "grading-results"
}

# S3 Configuration
variable "grading_bucket_name" {
  description = "S3 bucket name for grading files"
  type        = string
}

variable "grading_bucket_arn" {
  description = "S3 bucket ARN for grading files"
  type        = string
}

# Monitoring Configuration
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "enable_monitoring_port" {
  description = "Enable monitoring port for health checks"
  type        = bool
  default     = false
}

variable "monitoring_port" {
  description = "Port for monitoring/health checks"
  type        = number
  default     = 8080
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

# Service Discovery
variable "enable_service_discovery" {
  description = "Enable service discovery"
  type        = bool
  default     = false
}

# Health Check
variable "health_check_command" {
  description = "Health check command for container"
  type        = list(string)
  default     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
