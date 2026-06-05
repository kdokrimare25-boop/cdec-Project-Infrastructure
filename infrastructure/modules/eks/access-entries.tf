# access-entries.tf — IAM principals allowed to call the Kubernetes API (replaces aws-auth for API mode)

data "aws_caller_identity" "current" {}

locals {
  # Static map keys are required: for_each cannot use a set when values include apply-time ARNs.
  cluster_admin_entries = merge(
    { for idx, arn in var.cluster_admin_principal_arns : "principal-${idx}" => arn },
    var.include_caller_as_cluster_admin ? { "terraform-caller" = data.aws_caller_identity.current.arn } : {},
  )

  cluster_admin_principal_arns = values(local.cluster_admin_entries)
}

resource "aws_eks_access_entry" "cluster_admin" {
  for_each = local.cluster_admin_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"

  tags = merge(
    local.base_tags,
    {
      Name = "${var.cluster_name}-admin-access"
    },
  )

  depends_on = [aws_eks_cluster.this]
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = local.cluster_admin_entries

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.cluster_admin]
}
