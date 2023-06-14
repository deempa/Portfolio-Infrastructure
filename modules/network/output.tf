output "public-subnet-1-id" {
  value       = aws_subnet.lior-public-subnet-k8s-a.id
  description = "description"
}

output "public-subnet-2-id" {
  value       = aws_subnet.lior-public-subnet-k8s-b.id
  description = "description"
}

output "vpc-id" {
  value       = aws_vpc.this.id
  description = "description"
}

