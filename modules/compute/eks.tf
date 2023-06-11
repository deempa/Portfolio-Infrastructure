resource "aws_eks_cluster" "lior-k8s" {
  name     = "${var.prefix}-Cluster"
  version  = "1.27"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    endpoint_public_access = true
    subnet_ids = [
      var.public-subnet-1-id,
      var.public-subnet-2-id
    ]
  }
  tags = {
    Name = "${var.prefix}-Cluster"
  }
  depends_on = [aws_iam_role_policy_attachment.demo_amazon_eks_cluster_policy]
}


resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.lior-k8s.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.19.0-eksbuild.1"
  resolve_conflicts           = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.private_nodes,
  ]
}