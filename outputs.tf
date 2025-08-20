# Outputs for 3-Tier Architecture with Async Grading System

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ips" {
  description = "IP addresses of the NAT Gateways"
  value       = module.vpc.nat_gateway_ips
}

# Web Application Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${module.compute.load_balancer_dns_name}"
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

# Database Outputs
output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.database_endpoint
  sensitive   = true
}

output "database_port" {
  description = "RDS instance port"
  value       = module.database.database_port
}

# Storage Outputs
output "grading_bucket_name" {
  description = "Name of the grading S3 bucket"
  value       = module.storage.bucket_id
}

output "grading_bucket_arn" {
  description = "ARN of the grading S3 bucket"
  value       = module.storage.bucket_arn
}

# Messaging Outputs
output "mq_broker_endpoint" {
  description = "Amazon MQ broker endpoint"
  value       = module.messaging.mq_broker_endpoint
  sensitive   = true
}

output "mq_console_url" {
  description = "Amazon MQ console URL"
  value       = module.messaging.mq_broker_console_url
  sensitive   = true
}

output "mq_broker_id" {
  description = "Amazon MQ broker ID"
  value       = module.messaging.mq_broker_id
}

# ECS Grading System Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_grading.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_grading.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS grading service"
  value       = module.ecs_grading.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs_grading.task_definition_arn
}

output "ecs_log_group_name" {
  description = "Name of the ECS CloudWatch log group"
  value       = module.ecs_grading.cloudwatch_log_group_name
}

# System Integration Information
output "grading_system_info" {
  description = "Information about the grading system integration"
  value = {
    queue_name        = var.grading_queue_name
    result_queue_name = var.grading_result_queue_name
    s3_bucket         = module.storage.bucket_id
    ecs_cluster       = module.ecs_grading.ecs_cluster_name
    mq_broker_id      = module.messaging.mq_broker_id
  }
}

# SSM Parameter Names (for application configuration)
output "ssm_parameters" {
  description = "SSM parameter names for application configuration"
  value = {
    mq_endpoint = module.messaging.ssm_parameter_endpoint
    mq_username = module.messaging.ssm_parameter_username
    mq_password = module.messaging.ssm_parameter_password
  }
}
