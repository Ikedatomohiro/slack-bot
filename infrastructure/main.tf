provider "aws" {
  region = var.aws_region
}

module "lambda" {
  source                   = "./modules/lambda"
  lambda_envs              = var.lambda_envs
  region                   = var.aws_region
  ec2                      = module.ec2
  cloudwatch_log_retention = 60
}

variable "lambda_envs" {}

module "ec2" {
  source = "./modules/ec2"
}
