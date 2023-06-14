data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:eu-west-2:644435390668:secret:lior-secrets-WXWqth"
}

data "aws_secretsmanager_secret_version" "secret-version" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}