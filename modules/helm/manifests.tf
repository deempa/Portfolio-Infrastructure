resource "kubectl_manifest" "appsofapp" {
  yaml_body  = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: appsofapp
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: default
    server: 'https://kubernetes.default.svc'
  source:
    path: ./infra-apps/
    repoURL: 'git@github.com:deempa/GitOps-Config-Portfolio.git'
    targetRevision: HEAD
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
  project: default
YAML
  depends_on = [helm_release.argocd]
}