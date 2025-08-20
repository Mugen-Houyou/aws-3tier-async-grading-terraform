variable "environment_name" {
  description = "Environment name prefix"
  type        = string
}

variable "bucket_suffix" {
  description = "Suffix for bucket name to ensure uniqueness"
  type        = string
  default     = "files"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_lifecycle" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

variable "lifecycle_expiration_days" {
  description = "Number of days after which objects expire"
  type        = number
  default     = 365
}

variable "enable_s3_notifications" {
  description = "Enable S3 event notifications"
  type        = bool
  default     = false
}

variable "notification_queues" {
  description = "List of SQS queues for S3 notifications"
  type = list(object({
    arn           = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = []
}

variable "enable_metrics" {
  description = "Enable CloudWatch metrics for S3 bucket"
  type        = bool
  default     = true
}

variable "enable_cors" {
  description = "Enable CORS configuration for S3 bucket"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
