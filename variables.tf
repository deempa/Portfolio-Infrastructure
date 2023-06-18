variable "prefix" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "instance_tenancy" {
  type = string
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "assign_generated_ipv6_cidr_block" {
  type = bool
}

variable "subnets_cidr_block" {
  type = list(any)
}

variable "subnets_availability_zone" {
  type = list(any)
}

variable "map_public_ip_on_launch" {
  type = bool
}

variable "capacity_type" {
  type = string
}

variable "instance_types" {
  type = list(any)
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "ami_type" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "force_update_version" {
  type = string
}

variable "max_unavailable" {
  type = number
}

variable "subnet_count" {
  type = number
}

variable "base_subnet_cidr" {
  type = string
}