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
  config_dashboard.ndjson: |
    {"attributes":{"fieldAttrs":"{\"log\":{\"count\":5},\"message\":{\"count\":4},\"stream\":{\"count\":2},\"tag\":{\"count\":2}}","fieldFormatMap":"{}","fields":"[]","name":"test","runtimeFieldMap":"{}","sourceFilters":"[]","timeFieldName":"@timestamp","title":"logstash-*","typeMeta":"{}"},"coreMigrationVersion":"8.8.0","created_at":"2023-06-10T20:28:08.119Z","id":"020ce03e-7f49-431e-9386-ae25934ac7b3","managed":false,"references":[],"type":"index-pattern","typeMigrationVersion":"8.0.0","updated_at":"2023-06-10T20:59:52.387Z","version":"WzEzMCwyXQ=="}
    {"attributes":{"description":"","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"},"optionsJSON":"{\"useMargins\":true,\"syncColors\":false,\"syncCursor\":true,\"syncTooltips\":false,\"hidePanelTitles\":false}","panelsJSON":"[{\"version\":\"8.8.0\",\"type\":\"lens\",\"gridData\":{\"x\":0,\"y\":0,\"w\":10,\"h\":15,\"i\":\"6b609c6a-294a-43e0-8d51-cfe452c448fe\"},\"panelIndex\":\"6b609c6a-294a-43e0-8d51-cfe452c448fe\",\"embeddableConfig\":{\"attributes\":{\"title\":\"\",\"description\":\"\",\"visualizationType\":\"lnsLegacyMetric\",\"type\":\"lens\",\"references\":[{\"type\":\"index-pattern\",\"id\":\"020ce03e-7f49-431e-9386-ae25934ac7b3\",\"name\":\"indexpattern-datasource-layer-3774e0ac-fa97-4693-86b0-b57cd6e37069\"}],\"state\":{\"visualization\":{\"layerId\":\"3774e0ac-fa97-4693-86b0-b57cd6e37069\",\"accessor\":\"3844e288-b4ad-4e03-87f8-568af0084915\",\"layerType\":\"data\"},\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filters\":[],\"datasourceStates\":{\"formBased\":{\"layers\":{\"3774e0ac-fa97-4693-86b0-b57cd6e37069\":{\"columns\":{\"3844e288-b4ad-4e03-87f8-568af0084915X0\":{\"label\":\"Part of count(kql='Added and new and order')\",\"dataType\":\"number\",\"operationType\":\"count\",\"isBucketed\":false,\"scale\":\"ratio\",\"sourceField\":\"___records___\",\"filter\":{\"query\":\"Added and new and order\",\"language\":\"kuery\"},\"params\":{\"emptyAsNull\":false},\"customLabel\":true},\"3844e288-b4ad-4e03-87f8-568af0084915\":{\"label\":\"Total Orders\",\"dataType\":\"number\",\"operationType\":\"formula\",\"isBucketed\":false,\"scale\":\"ratio\",\"params\":{\"formula\":\"count(kql='Added and new and order')\",\"isFormulaBroken\":false,\"format\":{\"id\":\"number\",\"params\":{\"decimals\":2}}},\"references\":[\"3844e288-b4ad-4e03-87f8-568af0084915X0\"],\"customLabel\":true}},\"columnOrder\":[\"3844e288-b4ad-4e03-87f8-568af0084915\",\"3844e288-b4ad-4e03-87f8-568af0084915X0\"],\"incompleteColumns\":{},\"sampling\":1}}},\"textBased\":{\"layers\":{}}},\"internalReferences\":[],\"adHocDataViews\":{}}},\"enhancements\":{}}},{\"version\":\"8.8.0\",\"type\":\"lens\",\"gridData\":{\"x\":10,\"y\":0,\"w\":7,\"h\":15,\"i\":\"f8b594a1-41f5-43dc-b8c7-c0542b5e2a96\"},\"panelIndex\":\"f8b594a1-41f5-43dc-b8c7-c0542b5e2a96\",\"embeddableConfig\":{\"attributes\":{\"title\":\"\",\"description\":\"\",\"visualizationType\":\"lnsLegacyMetric\",\"type\":\"lens\",\"references\":[{\"type\":\"index-pattern\",\"id\":\"020ce03e-7f49-431e-9386-ae25934ac7b3\",\"name\":\"indexpattern-datasource-layer-c0237f31-7637-4d87-a81f-cf8bb65bf560\"}],\"state\":{\"visualization\":{\"layerId\":\"c0237f31-7637-4d87-a81f-cf8bb65bf560\",\"accessor\":\"03f78c65-3daf-4f82-b750-e5b9c92f93cc\",\"layerType\":\"data\"},\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filters\":[],\"datasourceStates\":{\"formBased\":{\"layers\":{\"c0237f31-7637-4d87-a81f-cf8bb65bf560\":{\"columns\":{\"03f78c65-3daf-4f82-b750-e5b9c92f93cc\":{\"label\":\"Total Removed Orders\",\"dataType\":\"number\",\"operationType\":\"unique_count\",\"scale\":\"ratio\",\"sourceField\":\"log.keyword\",\"isBucketed\":false,\"filter\":{\"query\":\"Removed and order\",\"language\":\"kuery\"},\"params\":{\"emptyAsNull\":true},\"customLabel\":true}},\"columnOrder\":[\"03f78c65-3daf-4f82-b750-e5b9c92f93cc\"],\"sampling\":1,\"incompleteColumns\":{}}}},\"textBased\":{\"layers\":{}}},\"internalReferences\":[],\"adHocDataViews\":{}}},\"enhancements\":{}}}]","timeRestore":false,"title":"OrdersApp-Dashboard","version":1},"coreMigrationVersion":"8.8.0","created_at":"2023-06-10T21:42:17.579Z","id":"abbe1bb0-07d7-11ee-a55a-5bd83977df4b","managed":false,"references":[{"id":"020ce03e-7f49-431e-9386-ae25934ac7b3","name":"6b609c6a-294a-43e0-8d51-cfe452c448fe:indexpattern-datasource-layer-3774e0ac-fa97-4693-86b0-b57cd6e37069","type":"index-pattern"},{"id":"020ce03e-7f49-431e-9386-ae25934ac7b3","name":"f8b594a1-41f5-43dc-b8c7-c0542b5e2a96:indexpattern-datasource-layer-c0237f31-7637-4d87-a81f-cf8bb65bf560","type":"index-pattern"}],"type":"dashboard","typeMigrationVersion":"8.7.0","updated_at":"2023-06-10T21:42:17.579Z","version":"WzI2NiwyXQ=="}
    {"excludedObjects":[],"excludedObjectsCount":0,"exportedCount":2,"missingRefCount":0,"missingReferences":[]}
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
  config_dashboard.json: |
    {
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": {
              "type": "datasource",
              "uid": "grafana"
            },
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "description": "Example dashboard for monitoring Flask webapps using prometheus_flask_exporter",
      "editable": true,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "id": 28,
      "links": [],
      "liveNow": false,
      "panels": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 0,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 12,
            "w": 10,
            "x": 0,
            "y": 0
          },
          "id": 2,
          "links": [],
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "pluginVersion": "9.3.6",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "rate(flask_http_request_duration_seconds_count{status=\"200\"}[$__rate_interval])",
              "format": "time_series",
              "interval": "",
              "intervalFactor": 1,
              "legendFormat": "{{ path }}",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "Requests per second",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 12,
            "w": 6,
            "x": 10,
            "y": 0
          },
          "id": 4,
          "links": [],
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.6",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(flask_http_request_duration_seconds_count{status!=\"200\"}[$__rate_interval]))",
              "format": "time_series",
              "interval": "",
              "intervalFactor": 1,
              "legendFormat": "errors",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "Errors per second",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 0,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 12,
            "w": 8,
            "x": 16,
            "y": 0
          },
          "id": 13,
          "links": [],
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "pluginVersion": "9.3.6",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "expr": "increase(flask_http_request_total[1m])",
              "format": "time_series",
              "interval": "",
              "intervalFactor": 1,
              "legendFormat": "HTTP {{ status }}",
              "refId": "A"
            }
          ],
          "title": "Total requests per minute",
          "type": "timeseries"
        }
      ],
      "refresh": "5s",
      "schemaVersion": 37,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-5m",
        "to": "now"
      },
      "timepicker": {
        "refresh_intervals": [],
        "time_options": [
          "5m",
          "15m",
          "1h",
          "6h",
          "12h",
          "24h",
          "2d",
          "7d",
          "30d"
        ]
      },
      "timezone": "",
      "title": "Prometheus Flask exporter example dashboard",
      "uid": "_eX4mpl3",
      "version": 3,
      "weekStart": ""
    }
YAML
    depends_on = [ helm_release.argocd ]
}