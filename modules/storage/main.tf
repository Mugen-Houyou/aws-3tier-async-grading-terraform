# S3 Storage Module for Grading System

# S3 Bucket for grading files
resource "aws_s3_bucket" "grading" {
  bucket = "${var.environment_name}-grading-${var.bucket_suffix}"

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-bucket"
    Purpose = "AsyncGrading"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "grading" {
  bucket = aws_s3_bucket.grading.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "grading" {
  bucket = aws_s3_bucket.grading.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "grading" {
  bucket = aws_s3_bucket.grading.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "grading" {
  count = var.enable_lifecycle ? 1 : 0
  
  bucket = aws_s3_bucket.grading.id

  rule {
    id     = "grading_files_lifecycle"
    status = "Enabled"

    # Move to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete after specified days
    expiration {
      days = var.lifecycle_expiration_days
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Notification for SQS (optional)
resource "aws_s3_bucket_notification" "grading" {
  count = var.enable_s3_notifications ? 1 : 0
  
  bucket = aws_s3_bucket.grading.id

  dynamic "queue" {
    for_each = var.notification_queues
    content {
      queue_arn = queue.value.arn
      events    = queue.value.events
      
      dynamic "filter_prefix" {
        for_each = queue.value.filter_prefix != null ? [queue.value.filter_prefix] : []
        content {
          value = filter_prefix.value
        }
      }
      
      dynamic "filter_suffix" {
        for_each = queue.value.filter_suffix != null ? [queue.value.filter_suffix] : []
        content {
          value = filter_suffix.value
        }
      }
    }
  }
}

# CloudWatch Metrics for S3 bucket
resource "aws_s3_bucket_metric" "grading" {
  count = var.enable_metrics ? 1 : 0
  
  bucket = aws_s3_bucket.grading.id
  name   = "grading-metrics"
}

# S3 Bucket CORS Configuration (if needed for web uploads)
resource "aws_s3_bucket_cors_configuration" "grading" {
  count = var.enable_cors ? 1 : 0
  
  bucket = aws_s3_bucket.grading.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
