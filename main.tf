module "network" {
  source = "./modules/network"

  prefix = var.prefix
  vpc_cidr_block     = var.vpc_cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  subnets_cidr_block = var.subnets_cidr_block
  subnets_availability_zone = var.subnets_availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

module "compute" {
  source = "./modules/compute"
  depends_on = [module.network]

  prefix = var.prefix
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  scaling_config = {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }
  ami_type = var.ami_type
  disk_size = var.disk_size
  force_update_version = var.force_update_version
  max_unavailable = var.max_unavailable

  public-subnet-1-id      = module.network.public-subnet-1-id
  public-subnet-2-id      = module.network.public-subnet-2-id
  vpc-id                  = module.network.vpc-id
}
