data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_tasks_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "bookstore_ecs_execution_role" {
  name               = "bookstore-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_role_policy.json
}

resource "aws_iam_role" "bookstore_ecs_task_role" {
  name               = "bookstore-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ecr_attachment" {
  role       = aws_iam_role.bookstore_ecs_execution_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_policy" "ecs_task_cloudwatch_logs_policy" {
  name        = "ecs-task-cloudwatch-logs-policy"
  description = "Policy for ECS task to write logs to CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log-group-name}:log-stream:*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_cloudwatch_logs_attachment" {
  name       = "ecs-task-cloudwatch-logs-attachment"
  roles      = [aws_iam_role.bookstore_ecs_execution_role.name]
  policy_arn = aws_iam_policy.ecs_task_cloudwatch_logs_policy.arn
}
