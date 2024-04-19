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

resource "aws_security_group" "bookstore_ecs_sec_group" {
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

# Create internet gateway
resource "aws_internet_gateway" "bookstore_igw" {
  vpc_id = aws_vpc.bookstore_vpc.id
}

# Attach internet gateway to public subnet
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

# If your ECS tasks need access specifically to Amazon Elastic Container Registry (ECR)
# without accessing the broader internet, you can use a VPC Endpoint for ECR. This allows your
# tasks in the private subnet to pull Docker images from ECR without needing a NAT Gateway or
# NAT instance.
resource "aws_vpc_endpoint" "bookstore_vpc_ecr_endpoint" {
  vpc_id            = aws_vpc.bookstore_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.bookstore_ecs_sec_group.id]
  subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "bookstore-vpc-ecr-endpoint"
  }
}

resource "aws_lb" "bookstore_lb" {
  name               = "bookstore-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bookstore_ecs_sec_group.id]
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
