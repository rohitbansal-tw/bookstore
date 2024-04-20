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
  type    = string
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

resource "aws_security_group" "bookstore_api_sg" {
  name        = "bookstore-ecs-security-group"
  description = "Security group for Bookstore ECS tasks"
  vpc_id      = aws_vpc.bookstore_vpc.id

  // Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bookstore-ecs-security-group"
  }
}

resource "aws_lb" "bookstore_lb" {
  name               = "bookstore-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bookstore_api_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "bookstore-lb"
  }
}

resource "aws_lb_target_group" "bookstore_target_group" {
  name        = "bookstore-target-group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.bookstore_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "bookstore_listener" {
  load_balancer_arn = aws_lb.bookstore_lb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bookstore_target_group.arn
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
    security_groups  = [aws_security_group.bookstore_api_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bookstore_target_group.arn
    container_name   = "bookstore-api"
    container_port   = 8000
  }

  depends_on = [aws_lb_target_group.bookstore_target_group]
}