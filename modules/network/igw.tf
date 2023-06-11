resource "aws_internet_gateway" "lior-igw-k8s" {
  vpc_id = aws_vpc.lior-vpc-k8s.id

  tags = {
    Name = "${var.prefix}-igw-k8s"
  }
}