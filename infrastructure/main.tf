provider "aws" {
  region = var.aws_region
}

variable "edash_rag_envs" {}

module "edash_rag" {
  source                   = "./modules/edash_rag"
  edash_rag_envs           = var.edash_rag_envs
  region                   = var.aws_region
  cloudwatch_log_retention = 60
}
