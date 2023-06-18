
resource "aws_subnet" "public" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.base_subnet_cidr, 2, count.index)
  availability_zone       = var.subnets_availability_zone[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name                             = "${var.prefix}-public-subnet-k8s-${count.index}"
    "kubernetes.io/cluster/Lior-Portfolio-Cluster" = "shared"
    "kubernetes.io/role/elb"         = "1"
  }
}


# resource "aws_subnet" "lior-public-subnet-k8s-b" {
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = var.subnets_cidr_block[1]
#   availability_zone       = var.subnets_availability_zone[1]
#   map_public_ip_on_launch = var.map_public_ip_on_launch

#   tags = {
#     Name                             = "${var.prefix}-public-subnet-k8s-b"
#     "kubernetes.io/cluster/Lior-Portfolio-Cluster" = "shared"
#     "kubernetes.io/role/elb"         = "1"
#   }
# }