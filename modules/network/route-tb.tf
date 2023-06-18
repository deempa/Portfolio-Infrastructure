
resource "aws_route_table" "lior-public-tb" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id

  }

  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

# resource "aws_route_table_association" "lior-public-subnet-k8s-a" {
#   subnet_id      = aws_subnet.lior-public-subnet-k8s-a.id
#   route_table_id = aws_route_table.lior-public-tb.id
# }

# resource "aws_route_table_association" "lior-public-subnet-k8s-b" {
#   subnet_id      = aws_subnet.lior-public-subnet-k8s-b.id
#   route_table_id = aws_route_table.lior-public-tb.id
# }

resource "aws_route_table_association" "public-subnet-k8s" {
  count           = var.subnet_count
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.lior-public-tb.id
}