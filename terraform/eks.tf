resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.DEFAULT_NAME}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = local.ALL_SUBNETS_ID
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids = [
      aws_security_group.eks_control_plane.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = "${local.DEFAULT_NAME}-eks-cluster"
  }
}

resource "aws_eks_node_group" "nodes_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${local.DEFAULT_NAME}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = local.PRIVATE_SUBNETS_ID
  instance_types  = ["t3.medium"]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policies
  ]

  tags = {
    Name = "${local.DEFAULT_NAME}-nodes"
  }
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${local.DEFAULT_NAME}-eks-nodes-"

  vpc_security_group_ids = [
    aws_security_group.eks_nodes.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.DEFAULT_NAME}-eks-node"
    }
  }
}

