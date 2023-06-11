resource "kubectl_manifest" "apache-log-parser" {
    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: apache-log-parser
data:
  fluentd.conf: |

    # Ignore fluentd own events
    <match fluent.**>
      @type null
    </match>

    # HTTP input for the liveness and readiness probes
    <source>
      @type http
      port 9880
    </source>

    # Throw the healthcheck to the standard output instead of forwarding it
    <match fluentd.healthcheck>
      @type stdout
    </match>

    # Get the logs from the containers running in the cluster
    # This block parses logs using an expression valid for the Apache log format
    # Update this depending on your application log format
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /opt/bitnami/fluentd/logs/buffers/fluentd-docker.pos
      tag www.log
      <parse>
        @type regexp
        expression /^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] \\"(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?\\" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$/
        time_format %d/%b/%Y:%H:%M:%S %z
      </parse>
    </source>

    # Forward all logs to the aggregators
    <match **>
      @type forward
      <server>
        host fluentd-0.fluentd-headless.default.svc.cluster.local
        port 24224
      </server>

      <buffer>
        @type file
        path /opt/bitnami/fluentd/logs/buffers/logs.buffer
        flush_thread_count 2
        flush_interval 5s
      </buffer>
    </match>
YAML

  depends_on = [ aws_eks_node_group.private_nodes ]
}

resource "kubectl_manifest" "elasticsearch-output" {
    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-output
data:
  fluentd.conf: |

    # Ignore fluentd own events
    <match fluent.**>
      @type null
    </match>

    # TCP input to receive logs from the forwarders
    <source>
      @type forward
      bind 0.0.0.0
      port 24224
    </source>

    # HTTP input for the liveness and readiness probes
    <source>
      @type http
      bind 0.0.0.0
      port 9880
    </source>

    # Throw the healthcheck to the standard output instead of forwarding it
    <match fluentd.healthcheck>
      @type stdout
    </match>

    # Send the logs to the standard output
    <match **>
      @type elasticsearch
      include_tag_key true
      host "#{ENV['ELASTICSEARCH_HOST']}"
      port "#{ENV['ELASTICSEARCH_PORT']}"
      logstash_format true
      <buffer>
        @type file
        path /opt/bitnami/fluentd/logs/buffers/logs.buffer
        flush_thread_count 2
        flush_interval 5s
      </buffer>
    </match>
YAML

  depends_on = [ aws_eks_node_group.private_nodes ]
}

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
  name: ordersdashboard
  namespace: default
data:
  my-dashboard.json: |
    ${indent(4, file("${path.module}/dashboards/kibana_dashboard.ndjson"))}
YAML

    depends_on = [ helm_release.argocd ]
}

resource "kubectl_manifest" "grafanadashboard" {
    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: ordersdashboard
  namespace: default
  labels:
    grafana_dashboard: "1"
data:
  my-dashboard.json: |
    ${indent(4, file("${path.module}/dashboards/grafana_dashboard.json"))}
YAML
    depends_on = [ helm_release.argocd ]
}