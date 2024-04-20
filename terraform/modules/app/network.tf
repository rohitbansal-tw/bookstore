resource "aws_vpc" "bookstore_vpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = false
  enable_dns_support               = true
  enable_dns_hostnames             = true
  tags = {
    Name = "bookstore-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "bookstore-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "bookstore-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "bookstore-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "bookstore-private-subnet-2"
  }
}

# Launch tasks in a private subnet and make sure you have AWS PrivateLink endpoints configured
# in your VPC, for the services you need (ECR for image pull authentication, S3 for image
# layers, and AWS Secrets Manager for secrets).
#
# https://stackoverflow.com/questions/61265108/aws-ecs-fargate-resourceinitializationerror-unable-to-pull-secrets-or-registry

resource "aws_security_group" "ecr_sg" {
  name        = "ecr-endpoint-sg"
  description = "Security group for ECR endpoint"

  vpc_id = aws_vpc.bookstore_vpc.id

  # Allow inbound traffic from ECR endpoint
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to ECR endpoint
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "secrets_manager_sg" {
  name        = "secrets-manager-endpoint-sg"
  description = "Security group for AWS Secrets Manager endpoint"

  vpc_id = aws_vpc.bookstore_vpc.id

  # Allow inbound traffic from Secrets Manager endpoint
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to Secrets Manager endpoint
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_ecr" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecr_sg.id]
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "bookstore-ecr-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_ecr_api" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecr_sg.id]
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "bookstore-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_cloudwatch" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "bookstore-cloudwatch-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "bookstore-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_secrets_manager" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.secrets_manager_sg.id]
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "bookstore-secrets-manager-endpoint"
  }
}

# Create an internet gateway for the VPC to allow internet access for public subnets

resource "aws_internet_gateway" "bookstore_igw" {
  vpc_id = aws_vpc.bookstore_vpc.id
}

resource "aws_route_table" "bookstore_public_route_table" {
  vpc_id = aws_vpc.bookstore_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bookstore_igw.id
  }
  tags = {
    Name = "bookstore-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.bookstore_public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.bookstore_public_route_table.id
}
