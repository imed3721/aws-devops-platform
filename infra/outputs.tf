output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "database_identifier" {
  description = "RDS database identifier"
  value       = aws_db_instance.postgres.identifier
}

output "database_endpoint" {
  description = "Database endpoint; does not include credentials"
  value       = aws_db_instance.postgres.endpoint
}

output "database_publicly_accessible" {
  description = "Whether the database is publicly accessible"
  value       = aws_db_instance.postgres.publicly_accessible
}
