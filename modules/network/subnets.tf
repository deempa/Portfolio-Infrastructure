
resource "aws_subnet" "lior-public-subnet-k8s-a" {
  vpc_id                  = aws_vpc.lior-vpc-k8s.id
  cidr_block              = var.subnets_cidr_block[0]
  availability_zone       = var.subnets_availability_zone[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name                             = "${var.prefix}-public-subnet-k8s-a"
    "kubernetes.io/cluster/Lior-Portfolio-Cluster" = "shared"
    "kubernetes.io/role/elb"         = "1"
  }
}


resource "aws_subnet" "lior-public-subnet-k8s-b" {
  vpc_id                  = aws_vpc.lior-vpc-k8s.id
  cidr_block              = var.subnets_cidr_block[1]
  availability_zone       = var.subnets_availability_zone[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name                             = "${var.prefix}-public-subnet-k8s-b"
    "kubernetes.io/cluster/Lior-Portfolio-Cluster" = "shared"
    "kubernetes.io/role/elb"         = "1"
  }
}