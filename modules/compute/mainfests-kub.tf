resource "kubectl_manifest" "appsofapp" {
    yaml_body = <<YAML
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

    depends_on = [ helm_release.argocd ]
}

resource "kubectl_manifest" "kibanadashboard" {
    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: kibanadashboard
  namespace: default
data:
  my-dashboard-kibana.ndjson: |
    ${indent(4, file("${path.module}/dashboards/kibana_dashboard.ndjson"))}
YAML
}

resource "kubectl_manifest" "grafanadashboard" {
    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafanadashboard
  namespace: default
  labels:
    grafana_dashboard: "1"
data:
  my-dashboard-grafana.json: |
    ${indent(4, file("${path.module}/dashboards/grafana_dashboard.json"))}
YAML
}