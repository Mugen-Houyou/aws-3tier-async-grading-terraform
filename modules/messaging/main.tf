# Amazon MQ Module for Async Grading System

# Amazon MQ Broker
resource "aws_mq_broker" "grading_queue" {
  broker_name        = "${var.environment_name}-grading-mq"
  engine_type        = var.engine_type
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  
  # Security and Network
  security_groups    = [var.mq_security_group_id]
  subnet_ids         = var.subnet_ids
  publicly_accessible = var.publicly_accessible
  
  # Authentication
  user {
    username = var.admin_username
    password = var.admin_password
  }
  
  # Configuration
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  deployment_mode           = var.deployment_mode
  storage_type             = var.storage_type
  
  # Logging
  logs {
    general = var.enable_general_logs
    audit   = var.enable_audit_logs
  }
  
  # Maintenance
  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-mq"
    Purpose = "AsyncGrading"
  })
}

# CloudWatch Log Group for MQ logs
resource "aws_cloudwatch_log_group" "mq_logs" {
  count = var.enable_general_logs || var.enable_audit_logs ? 1 : 0
  
  name              = "/aws/amazonmq/broker/${var.environment_name}-grading-mq"
  retention_in_days = var.log_retention_days
  
  tags = merge(var.tags, {
    Name = "${var.environment_name}-mq-logs"
  })
}

# SSM Parameters for MQ connection details
resource "aws_ssm_parameter" "mq_broker_endpoint" {
  name  = "/${var.environment_name}/mq/broker-endpoint"
  type  = "String"
  value = aws_mq_broker.grading_queue.instances[0].endpoints[0]
  
  tags = merge(var.tags, {
    Name = "${var.environment_name}-mq-endpoint"
  })
}

resource "aws_ssm_parameter" "mq_username" {
  name  = "/${var.environment_name}/mq/username"
  type  = "String"
  value = var.admin_username
  
  tags = merge(var.tags, {
    Name = "${var.environment_name}-mq-username"
  })
}

resource "aws_ssm_parameter" "mq_password" {
  name  = "/${var.environment_name}/mq/password"
  type  = "SecureString"
  value = var.admin_password
  
  tags = merge(var.tags, {
    Name = "${var.environment_name}-mq-password"
  })
}
