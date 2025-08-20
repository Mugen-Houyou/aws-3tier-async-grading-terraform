variable "environment_name" {
  description = "Environment name prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

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
