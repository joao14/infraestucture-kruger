# Definir el clúster ECS
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.resource_prefix}-ecs-cluster"
}

# Crear el rol IAM para ejecución de tareas ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.resource_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Política en línea para permitir acceso a Secrets Manager, CloudWatch Logs y S3
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "ecs-task-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "s3:PutObject",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Definición de la tarea ECS
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.resource_prefix}-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.ecs_memory
  cpu                      = var.ecs_cpu
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "app",
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_image}:latest",
    "memory": ${var.ecs_memory},
    "cpu": ${var.ecs_cpu},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "secrets": [
      {
        "name": "MESSAGE",
        "valueFrom": "${aws_secretsmanager_secret.app_secret.arn}"
      }
    ]
  }
]
DEFINITION
}

# Crear el servicio ECS en Fargate
resource "aws_ecs_service" "app_service" {
  name            = "${var.resource_prefix}-app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "${var.resource_prefix}-app-service"
  }
}
