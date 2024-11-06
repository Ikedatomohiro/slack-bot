variable "edash_rag_envs" {}
variable "region" {}
variable "cloudwatch_log_retention" {}
variable "availability_zone" {}
variable "edash_rag_network_envs" {
  description = "Network environment variables for the edash_rag module"
  type        = map(list(string))
}
