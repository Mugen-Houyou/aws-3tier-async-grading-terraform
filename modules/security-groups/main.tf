# Security Groups Module

# Load Balancer Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment_name}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Web Server Security Group
resource "aws_security_group" "web_server" {
  name_prefix = "${var.environment_name}-web-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH access (optional, for debugging)
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-web-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.environment_name}-db-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL/Aurora"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-db-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Amazon MQ Security Group
resource "aws_security_group" "mq" {
  name_prefix = "${var.environment_name}-mq-"
  vpc_id      = var.vpc_id

  # ActiveMQ Web Console
  ingress {
    description     = "ActiveMQ Web Console"
    from_port       = 8162
    to_port         = 8162
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  # ActiveMQ OpenWire
  ingress {
    description     = "ActiveMQ OpenWire"
    from_port       = 61617
    to_port         = 61617
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  # ActiveMQ AMQP
  ingress {
    description     = "ActiveMQ AMQP"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  # ActiveMQ STOMP
  ingress {
    description     = "ActiveMQ STOMP"
    from_port       = 61613
    to_port         = 61613
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  # ActiveMQ MQTT
  ingress {
    description     = "ActiveMQ MQTT"
    from_port       = 1883
    to_port         = 1883
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  # ActiveMQ WSS
  ingress {
    description     = "ActiveMQ WSS"
    from_port       = 61619
    to_port         = 61619
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server.id, aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-mq-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name_prefix = "${var.environment_name}-ecs-"
  vpc_id      = var.vpc_id

  # Allow inbound traffic from ALB (if ECS tasks need to be accessed directly)
  dynamic "ingress" {
    for_each = var.enable_ecs_alb_access ? [1] : []
    content {
      description     = "HTTP from ALB"
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [aws_security_group.alb.id]
    }
  }

  # Allow communication between ECS tasks
  ingress {
    description = "Inter-task communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # SSH access (optional, for EC2-based ECS)
  dynamic "ingress" {
    for_each = var.enable_ssh_access && var.enable_ecs_ssh ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-ecs-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
