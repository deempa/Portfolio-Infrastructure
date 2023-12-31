output "cluster_endpoint" {
  value = data.aws_eks_cluster.this.endpoint
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "cluster_ca_certificate" {
  value = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
}