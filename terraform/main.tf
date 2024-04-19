module "app" {
  source     = "./modules/app"
  aws_region = var.aws-region
  tags = {
    Environment = var.env
  }
}