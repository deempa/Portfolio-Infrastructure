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
  subnet_count = var.subnet_count
  base_subnet_cidr = var.base_subnet_cidr
}

module "eks" {
  source = "./modules/eks"
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
  public-subnets = module.network.public_subnets
  vpc-id                  = module.network.vpc-id
}

module "helm" {
  source = "./modules/helm"
  
  depends_on = [ module.eks ]
}