resource "aws_ecs_cluster" "this" {
  name = "product-service-${var.environment}"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "product-service-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  # Updated to valid Fargate CPU/memory combinations
  cpu    = var.environment == "prod" ? 1024 : 512  # 1024 for prod, 512 for others
  memory = var.environment == "prod" ? 2048 : 1024 # 2048 for prod, 1024 for others
  
  execution_role_arn = var.ecs_exec_role_arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "app",
    image     = var.ecr_repository_url,
    essential = true,
    portMappings = [{
      containerPort = 5000,
      hostPort      = 5000
    }],
    environment = [
      { name = "ENVIRONMENT", value = var.environment },
      { name = "DEBUG", value = "false" }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name,
        "awslogs-region"        = var.region,
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = "product-service-${var.environment}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = var.environment != "prod"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = 5000
  }
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
}

resource "aws_lb" "this" {
  name               = "product-service-${var.environment}"
  internal           = var.environment == "prod"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.environment == "prod"
}

resource "aws_lb_target_group" "this" {
  name        = "product-service-${var.environment}"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "ecs" {
  name        = "product-service-ecs-${var.environment}"
  description = "Allow inbound from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb" {
  name        = "product-service-lb-${var.environment}"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.environment == "prod" ? var.allowed_ips : ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "dynamodb" {
  name = "dynamodb-access-${var.environment}"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["dynamodb:*"],
      Effect   = "Allow",
      Resource = var.dynamodb_table_arn
    }]
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/product-service-${var.environment}"
  retention_in_days = var.environment == "prod" ? 365 : (var.environment == "qa" ? 30 : 7)
}