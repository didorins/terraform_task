# Output block to print values defined below after terraform apply is run.

# ALB DNS endpoint (http / :80)
output "elb_dns_name" {
  description = "Load balancer DNS endpoint"
  value       = aws_lb.app-lb.dns_name
}

# EFS endpoint
output "efs-id" {
  description = "EFS endpoint"
  value       = aws_efs_file_system.efs.id
}

# DB endpoint
 output "db-endpoint"{
description = "Connect to DB instance using this string. Grab PW from Parameter Store"
value = "mysql -h ${aws_db_instance.rds.endpoint} -P 3306 -u ${aws_db_instance.rds.username} -p"
}
