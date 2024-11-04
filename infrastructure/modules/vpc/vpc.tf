resource "aws_vpc" "edash_rag_vpc" {
  cidr_block = var.vpc_envs["edash_rag_vpc_cidr_block"]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.edash_rag_vpc.id
}