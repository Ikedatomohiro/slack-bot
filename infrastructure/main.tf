provider "aws" {
  region = var.aws_region
}

variable "lambda_envs" {}
variable "vpc_envs" {}

module "ec2" {
  source = "./modules/ec2"
}

module "lambda" {
  source                   = "./modules/lambda"
  lambda_envs              = var.lambda_envs
  region                   = var.aws_region
  ec2                      = module.ec2
  cloudwatch_log_retention = 60
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_envs = var.vpc_envs
}
