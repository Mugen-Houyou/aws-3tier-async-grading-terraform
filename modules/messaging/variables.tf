variable "environment_name" {
  description = "Environment name prefix"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for MQ broker"
  type        = list(string)
}

variable "mq_security_group_id" {
  description = "Security group ID for MQ broker"
  type        = string
}

variable "engine_type" {
  description = "MQ engine type"
  type        = string
  default     = "ActiveMQ"
  
  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.engine_type)
    error_message = "Engine type must be either ActiveMQ or RabbitMQ."
  }
}

variable "engine_version" {
  description = "MQ engine version"
  type        = string
  default     = "5.17.6"
}

variable "host_instance_type" {
  description = "MQ broker instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "deployment_mode" {
  description = "Deployment mode for MQ broker"
  type        = string
  default     = "SINGLE_INSTANCE"
  
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ"], var.deployment_mode)
    error_message = "Deployment mode must be either SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ."
  }
}

variable "storage_type" {
  description = "Storage type for MQ broker"
  type        = string
  default     = "ebs"
}

variable "publicly_accessible" {
  description = "Whether the MQ broker is publicly accessible"
  type        = bool
  default     = false
}

variable "admin_username" {
  description = "Admin username for MQ broker"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password for MQ broker"
  type        = string
  sensitive   = true
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "enable_general_logs" {
  description = "Enable general logging"
  type        = bool
  default     = true
}

variable "enable_audit_logs" {
  description = "Enable audit logging"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "maintenance_day_of_week" {
  description = "Day of week for maintenance window"
  type        = string
  default     = "SUNDAY"
}

variable "maintenance_time_of_day" {
  description = "Time of day for maintenance window (HH:MM)"
  type        = string
  default     = "03:00"
}

variable "maintenance_time_zone" {
  description = "Time zone for maintenance window"
  type        = string
  default     = "UTC"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
