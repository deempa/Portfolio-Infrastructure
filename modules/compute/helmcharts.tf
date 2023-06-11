resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.34.6"

  set {
    name  = "configs.credentialTemplates.ssh-creds.url"
    value = "git@github.com:deempa/GitOps-Config-Portfolio.git"
  }

  set {
    name  = "configs.credentialTemplates.ssh-creds.sshPrivateKey"
    value = base64decode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["ARGO_PRIVATE_KEY"])
  }

  set {
    name = "configs.params.secret.argocdServerAdminPassword"
    value = bcrypt(jsondecode("$2a$10$0ByDN.R8YdVRDyaSYCkqFO..nGaBzVTuMrymD4.y796CqQRmKPXsi"))
  }

  values = [
    "${file("./values/argocd-values.yaml")}"
  ]
}

