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