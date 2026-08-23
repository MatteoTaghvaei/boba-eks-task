# EKS cluster role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.DEFAULT_NAME}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.DEFAULT_NAME}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = local.IAM_POLICIES.EKS_CLUSTER.cluster
}

# EKS node role
resource "aws_iam_role" "eks_node_role" {
  name = "${local.DEFAULT_NAME}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.DEFAULT_NAME}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = local.IAM_POLICIES.EKS_NODE

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

# OIDC role
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

resource "aws_iam_role" "github_actions_role" {
  name = "${local.DEFAULT_NAME}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.DEFAULT_NAME}-github-actions-role"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_policies" {
  for_each = local.IAM_POLICIES.GITHUB_ACTIONS

  role       = aws_iam_role.github_actions_role.name
  policy_arn = each.value
}
