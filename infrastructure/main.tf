provider "aws" {
  region = var.aws_region
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source      = "./modules/lambda"
  lambda_envs = var.lambda_envs
  region      = var.aws_region
  ec2         = module.ec2
}

variable "lambda_envs" {}

module "ec2" {
  source = "./modules/ec2"
}
