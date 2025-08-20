output "mq_broker_id" {
  description = "ID of the MQ broker"
  value       = aws_mq_broker.grading_queue.id
}

output "mq_broker_arn" {
  description = "ARN of the MQ broker"
  value       = aws_mq_broker.grading_queue.arn
}

output "mq_broker_endpoint" {
  description = "Endpoint of the MQ broker"
  value       = aws_mq_broker.grading_queue.instances[0].endpoints[0]
  sensitive   = true
}

output "mq_broker_console_url" {
  description = "Console URL of the MQ broker"
  value       = aws_mq_broker.grading_queue.instances[0].console_url
  sensitive   = true
}

output "mq_username" {
  description = "MQ broker username"
  value       = var.admin_username
  sensitive   = true
}

output "ssm_parameter_endpoint" {
  description = "SSM parameter name for MQ endpoint"
  value       = aws_ssm_parameter.mq_broker_endpoint.name
}

output "ssm_parameter_username" {
  description = "SSM parameter name for MQ username"
  value       = aws_ssm_parameter.mq_username.name
}

output "ssm_parameter_password" {
  description = "SSM parameter name for MQ password"
  value       = aws_ssm_parameter.mq_password.name
}
