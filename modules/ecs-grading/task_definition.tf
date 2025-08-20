# ECS Task Definition for Grading Service
resource "aws_ecs_task_definition" "grading" {
  family                   = "${var.environment_name}-grading-task"
  network_mode             = var.use_fargate ? "awsvpc" : "bridge"
  requires_compatibilities = var.use_fargate ? ["FARGATE"] : ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "grading-worker"
      image = var.grading_image
      
      essential = true
      
      # Resource limits
      cpu    = var.container_cpu
      memory = var.container_memory
      
      # Environment variables
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment_name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "MQ_ENDPOINT_PARAM"
          value = var.mq_endpoint_parameter
        },
        {
          name  = "MQ_USERNAME_PARAM"
          value = var.mq_username_parameter
        },
        {
          name  = "MQ_PASSWORD_PARAM"
          value = var.mq_password_parameter
        },
        {
          name  = "GRADING_BUCKET"
          value = var.grading_bucket_name
        },
        {
          name  = "QUEUE_NAME"
          value = var.queue_name
        },
        {
          name  = "RESULT_QUEUE_NAME"
          value = var.result_queue_name
        }
      ]
      
      # Logging
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grading_tasks.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grading-worker"
        }
      }
      
      # Health check
      healthCheck = {
        command = var.health_check_command
        interval = 30
        timeout = 5
        retries = 3
        startPeriod = 60
      }
      
      # Working directory
      workingDirectory = "/app"
      
      # Port mappings (if needed for monitoring)
      portMappings = var.enable_monitoring_port ? [
        {
          containerPort = var.monitoring_port
          protocol      = "tcp"
        }
      ] : []
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-task"
  })
}

# ECS Service
resource "aws_ecs_service" "grading" {
  name            = "${var.environment_name}-grading-service"
  cluster         = aws_ecs_cluster.grading.id
  task_definition = aws_ecs_task_definition.grading.arn
  desired_count   = var.desired_count

  # Deployment configuration
  deployment_configuration {
    maximum_percent         = var.max_capacity_percent
    minimum_healthy_percent = var.min_capacity_percent
  }

  # Network configuration for Fargate
  dynamic "network_configuration" {
    for_each = var.use_fargate ? [1] : []
    content {
      subnets          = var.private_subnet_ids
      security_groups  = [var.ecs_security_group_id]
      assign_public_ip = false
    }
  }

  # Service discovery (optional)
  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.grading[0].arn
    }
  }

  # Auto Scaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-service"
  })
}

# Service Discovery (optional)
resource "aws_service_discovery_private_dns_namespace" "grading" {
  count = var.enable_service_discovery ? 1 : 0
  
  name = "${var.environment_name}-grading.local"
  vpc  = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-namespace"
  })
}

resource "aws_service_discovery_service" "grading" {
  count = var.enable_service_discovery ? 1 : 0
  
  name = "grading-worker"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.grading[0].id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_grace_period_seconds = 30

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-service-discovery"
  })
}
