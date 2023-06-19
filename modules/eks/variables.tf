variable "prefix" {
  type = string
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

variable "public-subnets" {
  description = "public subnets"
}

variable "vpc-id" {
  description = "vpc id"
}