output "public_subnets" {
  description = "List of all the subnets"
  value       = concat(aws_subnet.public[*].id)
}

output "vpc-id" {
  value       = aws_vpc.this.id
  description = "vpc id"
}

