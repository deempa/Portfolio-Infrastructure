data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:eu-west-2:644435390668:secret:lior-secrets-WXWqth"
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}

resource "kubectl_manifest" "external-secrets" {
    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: external-secrets
  namespace: default
data:
  DATABASE_USER: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_USER"])}
  DATABASE_PASS: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_PASS"])}
  DATABASE_HOST: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_HOST"])}
  DATABASE_NAME: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_NAME"])}  
  ARGO_PRIVATE_KEY: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["ARGO_PRIVATE_KEY"])}  
YAML
}

resource "kubectl_manifest" "mysql-secrets" {
    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: default
data:
  mysql-root-password: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_PASS"])} 
  mysql-replication-password: ${base64encode(jsondecode(data.aws_secretsmanager_secret_version.secret-version.secret_string)["DATABASE_PASS"])} 
  mysql-password: ""
YAML
}