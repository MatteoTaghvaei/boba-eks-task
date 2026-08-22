provider "helm" {
  kubernetes = {
    host                   = local.CLUSTER_ENDPOINT
    cluster_ca_certificate = base64decode(
      local.CLUSTER_CERTIFICATE
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      
      args = ["eks", "get-token", "--cluster-name", local.CLUSTER_NAME, "--region", var.aws_region, "--profile", var.profile, "--output", "json"
     ]
    }
  }
}

resource "helm_release" "traefik_ingress" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = "traefik"

  create_namespace = true
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  create_namespace = true
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  create_namespace = true

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
}