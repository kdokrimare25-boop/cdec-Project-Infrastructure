data "http" "controller_crds" {
  count = var.install_controller ? 1 : 0

  url = "https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml"
}

locals {
  controller_crds = var.install_controller ? [
    for document in split("---\n", trimspace(data.http.controller_crds[0].response_body)) :
    yamldecode(document)
    if trimspace(document) != "" && can(yamldecode(document))
  ] : []
}

resource "kubernetes_manifest" "controller_crds" {
  for_each = var.install_controller ? {
    for manifest in local.controller_crds :
    "${manifest.kind}/${manifest.metadata.name}" => manifest
  } : {}

  manifest = each.value
}

resource "kubernetes_namespace_v1" "ingress" {
  count = var.create_ingress ? 1 : 0

  metadata {
    name = var.ingress_namespace
  }
}

resource "kubernetes_service_account_v1" "load_balancer_controller" {
  count = var.install_controller ? 1 : 0

  metadata {
    name      = var.controller_service_account_name
    namespace = var.controller_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load_balancer_controller.arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.install_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.controller_chart_version
  namespace  = var.controller_namespace

  wait    = true
  timeout = 600

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.controller_service_account_name
  }

  set {
    name  = "crds.create"
    value = "false"
  }

  depends_on = [
    aws_iam_role_policy_attachment.load_balancer_controller,
    kubernetes_service_account_v1.load_balancer_controller,
    kubernetes_manifest.controller_crds,
  ]
}
