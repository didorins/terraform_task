# Resource block for RDS database. !Takes long time to provision!
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  max_allocated_storage  = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0.28"
  multi_az               = true
  instance_class         = var.db2_instance_class
  username               = var.rds-username
  password               = random_password.db-password.result
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_type           = "gp2"
  port                   = var.database_port
  db_subnet_group_name   = aws_db_subnet_group.db_sg.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name  = "MYSQL DB"
    Owner = "terraform"
  }
}

# Subnets in which DB resides
resource "aws_db_subnet_group" "db_sg" {
  description = "Subnets in which DB will be deployed"
  name        = "db private sg"
  subnet_ids  = [aws_subnet.private-1.id, aws_subnet.private-2.id]

  tags = {
    Name  = "DB subnet"
    Owner = "terraform"
  }
}

# SG of DB allowing SG of Web layer on given port
# To test connection run 'mysql -h mysql–instance1.123456789012.eu-central-1.rds.amazonaws.com -P 3306 -u dido -p' from EC2
resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "DB SG to only allow traffic from SG of app layer on given DB port"
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# Generate random string password for the DB Instance
resource "random_password" "db-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store DB password in Parameter Store
resource "aws_ssm_parameter" "secret" {
  name        = "/production/database/password/master"
  description = "RDS password"
  type        = "SecureString"
  value       = random_password.db-password.result
}
