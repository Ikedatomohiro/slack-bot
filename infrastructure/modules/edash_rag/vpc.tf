resource "aws_vpc" "edash_rag_vpc" {
  cidr_block = var.edash_rag_envs["EDASH_RAG_VPC_CIDR_BLOCK"]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.edash_rag_vpc.id
}