resource "aws_ecr_repository" "bookstore_api" {
  name                 = "bookstore-api"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}

resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecr.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr-policy"
  description = "IAM policy for ECR access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ],
      Resource = "*",
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ecr_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "null_resource" "build_and_push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      # Go to api folder
      cd ../api

      # Build the Docker image
      # docker build -t bookstore .

      # Tag the Docker image with ECR repository URI
      # docker tag bookstore:latest ${aws_ecr_repository.bookstore_api.repository_url}:latest

      # Authenticate Docker with ECR
      # aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.bookstore_api.repository_url}:latest

      # Push the Docker image to ECR
      # docker push ${aws_ecr_repository.bookstore_api.repository_url}:latest
    EOF
  }
}
