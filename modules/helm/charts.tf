resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.34.6"

  set {
    name  = "configs.params.server.insecure"
    value = true
  }

  set {
    name  = "repositories.private-repo.url"
    value = "git@github.com:deempa/GitOps-Config-Portfolio.git"
  }

  set {
    name  = "configs.credentialTemplates.ssh-creds.url"
    value = "git@github.com:deempa/GitOps-Config-Portfolio.git"
  }

  set {
    name  = "configs.credentialTemplates.ssh-creds.sshPrivateKey"
    value = base64decode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["ARGO_PRIVATE_KEY"])
  }
}
