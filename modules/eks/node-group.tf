resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "Lior-Node-Group"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.public-subnets
  capacity_type   = var.capacity_type
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.scaling_config["desired_size"]
    max_size     = var.scaling_config["max_size"]
    min_size     = var.scaling_config["min_size"]
  }

  ami_type = var.ami_type

  disk_size = var.disk_size

  force_update_version = var.force_update_version

  update_config {
    max_unavailable = var.max_unavailable
  }

  labels = {
    role = "general"
  }

  version = "1.27"
  depends_on = [
    aws_iam_role_policy_attachment.nodes_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.nodes_amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.nodes_amazon_ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.nodes_amazon_eks_ebs_csi_policy
  ]
}
