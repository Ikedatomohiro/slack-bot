variable "edash_rag_envs" {}
variable "edash_rag_network_envs" {}

module "edash_rag" {
  source                   = "./modules/edash_rag"
  edash_rag_envs           = var.edash_rag_envs
  region                   = var.aws_region
  cloudwatch_log_retention = 60
  availability_zone        = "ap-northeast-1a"
  edash_rag_network_envs   = var.edash_rag_network_envs
}
