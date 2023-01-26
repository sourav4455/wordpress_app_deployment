
output "endpoint" {
  value = aws_db_instance.wordpress-db.endpoint
}

output "secret_manager_secret_arn" {
  value = aws_secretsmanager_secret.rds_credentials.arn
}
