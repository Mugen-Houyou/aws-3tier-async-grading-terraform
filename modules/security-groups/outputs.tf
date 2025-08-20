output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "web_server_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_server.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "mq_security_group_id" {
  description = "ID of the MQ security group"
  value       = aws_security_group.mq.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}
