output "ecs_security_group_id" {
  value = aws_security_group.bookstore_api_sg.id
}

output "vpc_id" {
  value = aws_vpc.bookstore_vpc.id
}

output "public_subnet_id_1" {
  value = aws_subnet.public_subnet_1.id
}

output "private_subnet_id_2" {
  value = aws_subnet.private_subnet_2.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.bookstore_api.repository_url
}