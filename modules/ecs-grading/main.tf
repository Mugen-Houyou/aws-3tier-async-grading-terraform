# ECS Grading System Module

# ECS Cluster
resource "aws_ecs_cluster" "grading" {
  name = "${var.environment_name}-grading-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-cluster"
    Purpose = "AsyncGrading"
  })
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "grading" {
  cluster_name = aws_ecs_cluster.grading.name

  capacity_providers = var.use_fargate ? ["FARGATE", "FARGATE_SPOT"] : ["EC2"]

  dynamic "default_capacity_provider_strategy" {
    for_each = var.use_fargate ? [1] : []
    content {
      base              = 1
      weight            = 100
      capacity_provider = "FARGATE"
    }
  }
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "grading_tasks" {
  name              = "/ecs/${var.environment_name}-grading"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-logs"
  })
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.environment_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment_name}-ecs-task-execution-role"
  })
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "${var.environment_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment_name}-ecs-task-role"
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for ECS task to access SSM parameters and other AWS services
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.environment_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.environment_name}/mq/*",
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.environment_name}/grading/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${var.grading_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.grading_bucket_arn
        ]
      }
    ]
  })
}
