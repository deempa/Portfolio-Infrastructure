resource "aws_eks_cluster" "this" {
  name     = "${var.prefix}-Cluster"
  version  = "1.27"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    endpoint_public_access = true
    subnet_ids = var.public-subnets
  }
  tags = {
    Name = "${var.prefix}-Cluster"
  }
  depends_on = [aws_iam_role_policy_attachment.demo_amazon_eks_cluster_policy]
}


resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.19.0-eksbuild.1"
  resolve_conflicts           = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.this,
  ]
}

resource "aws_iam_role" "cluster_role" {
  name = "${var.prefix}-Cluster-Role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "demo_amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}