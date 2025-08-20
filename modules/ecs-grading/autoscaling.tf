# Auto Scaling for ECS Service

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "grading" {
  count = var.enable_autoscaling ? 1 : 0
  
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.grading.name}/${aws_ecs_service.grading.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-autoscaling-target"
  })
}

# Auto Scaling Policy - Scale Up
resource "aws_appautoscaling_policy" "grading_scale_up" {
  count = var.enable_autoscaling ? 1 : 0
  
  name               = "${var.environment_name}-grading-scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grading[0].resource_id
  scalable_dimension = aws_appautoscaling_target.grading[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.grading[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# Auto Scaling Policy - Memory Utilization
resource "aws_appautoscaling_policy" "grading_scale_memory" {
  count = var.enable_autoscaling && var.enable_memory_scaling ? 1 : 0
  
  name               = "${var.environment_name}-grading-scale-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.grading[0].resource_id
  scalable_dimension = aws_appautoscaling_target.grading[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.grading[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "grading_cpu_high" {
  count = var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.environment_name}-grading-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS grading service CPU utilization"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.grading.name
    ClusterName = aws_ecs_cluster.grading.name
  }

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "grading_memory_high" {
  count = var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.environment_name}-grading-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS grading service memory utilization"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.grading.name
    ClusterName = aws_ecs_cluster.grading.name
  }

  tags = merge(var.tags, {
    Name = "${var.environment_name}-grading-memory-alarm"
  })
}
