variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  type = string
}

variable "log-group-name" {
  default = "/ecs/bookstore-api"
  type = string
}

resource "aws_ecs_cluster" "bookstore_cluster" {
  name = "bookstore-cluster"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "bookstore_log_group" {
  name              = "/ecs/bookstore-api"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "bookstore_task" {
  family                   = "bookstore-task"
  execution_role_arn       = aws_iam_role.bookstore_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.bookstore_ecs_task_role.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name    = "bookstore-api"
      image   = "${aws_ecr_repository.bookstore_api.repository_url}:latest"
      command = ["sh", "-c", "poetry run main"],

      cpu       = 256
      memory    = 512
      essential = true

      networkMode = "awsvpc"
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]

      log_configuration = {
        log_driver = "awslogs"
        options = {
          "awslogs-group"         = var.log-group-name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "bookstore"
        }
      }
    }
  ])
}

resource "aws_service_discovery_private_dns_namespace" "bookstore_namespace" {
  name = "bookstore.local"
  vpc  = aws_vpc.bookstore_vpc.id
}

resource "aws_service_discovery_service" "bookstore_service_discovery" {
  name = "bookstore-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.bookstore_namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "bookstore_api" {
  name            = "bookstore-api"
  cluster         = aws_ecs_cluster.bookstore_cluster.id
  task_definition = aws_ecs_task_definition.bookstore_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.bookstore_ecs_sec_group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bookstore_target_group.arn
    container_name   = "bookstore-api"
    container_port   = 8000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.bookstore_service_discovery.arn
  }

  depends_on = [aws_lb_target_group.bookstore_target_group]
}