resource "aws_vpc" "lior-vpc-k8s" {
  cidr_block                       = var.vpc_cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}