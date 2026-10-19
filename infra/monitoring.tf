resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name        = "devops-platform-database-high-cpu"
  alarm_description = "Investigate sustained high database CPU usage"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name        = "devops-platform-database-low-storage"
  alarm_description = "Investigate low remaining database storage"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"
  statistic   = "Minimum"

  period              = 300
  evaluation_periods  = 1
  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  treat_missing_data = "notBreaching"
}
