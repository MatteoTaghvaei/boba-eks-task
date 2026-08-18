locals {
  DEFAULT_NAME = "${var.project_name}-${var.environment}"

  IAM_POLICIES = {
    EKS_CLUSTER = {
      cluster = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }

    EKS_NODE = {
      worker   = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      ecr_pull = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
      cni      = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }
  }

  ALL_SUBNETS_ID = flatten([
    [for subnet in aws_subnet.private_subnets : subnet.id],
    [for subnet in aws_subnet.public_subnets : subnet.id]
  ])

  PRIVATE_SUBNETS_ID = [for subnet in aws_subnet.private_subnets : subnet.id]

  EKS_INGRESS_RULES = {
    control_plane_from_nodes = {
      security_group_id = aws_security_group.eks_control_plane.id
      source_sg_id      = aws_security_group.eks_nodes.id
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
    }

    nodes_from_control_plane = {
      security_group_id = aws_security_group.eks_nodes.id
      source_sg_id      = aws_security_group.eks_control_plane.id
      from_port         = 10250
      to_port           = 10250
      protocol          = "tcp"
    }

    nodes_internal = {
      security_group_id = aws_security_group.eks_nodes.id
      source_sg_id      = aws_security_group.eks_nodes.id
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
    }
  }

  EKS_EGRESS_RULES = {
    control_plane = {
      security_group_id = aws_security_group.eks_control_plane.id
      cidr              = "0.0.0.0/0"
      protocol          = "-1"
    }

    nodes = {
      security_group_id = aws_security_group.eks_nodes.id
      cidr              = "0.0.0.0/0"
      protocol          = "-1"
    }
  }
}