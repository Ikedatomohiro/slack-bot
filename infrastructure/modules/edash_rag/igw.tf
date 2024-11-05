resource "aws_internet_gateway" "edash_rag_igw" {
  vpc_id = aws_vpc.edash_rag_vpc.id
}

resource "aws_subnet" "edash_rag_public_subnet" {
  vpc_id                  = aws_vpc.edash_rag_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
}

resource "aws_route_table" "edash_rag_public_rt" {
  vpc_id = aws_vpc.edash_rag_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.edash_rag_igw.id
  }
}

resource "aws_route_table_association" "edash_rag_public_rt_assoc" {
  subnet_id      = aws_subnet.edash_rag_public_subnet.id
  route_table_id = aws_route_table.edash_rag_public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.edash_rag_public_subnet.id
}

resource "aws_subnet" "edash_rag_private_subnet" {
  vpc_id            = aws_vpc.edash_rag_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone
}

resource "aws_route_table" "edash_rag_private_rt" {
  vpc_id = aws_vpc.edash_rag_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "edash_rag_private_rt_assoc" {
  subnet_id      = aws_subnet.edash_rag_private_subnet.id
  route_table_id = aws_route_table.edash_rag_private_rt.id
}
