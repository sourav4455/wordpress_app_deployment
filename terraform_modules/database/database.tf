## Creating an RDS MySQL Database

###### DB subnet group ######
resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.environment}-db_subnet"
  subnet_ids = "${var.db_subnet_ids}"

  tags {
    Name        = "${var.environment}-db_subnet"
    Environment = "${var.environment}"
  }
}

###### DB Instance ######

# Generating a random DB root password
resource "random_password" "db_password" {
  length  = 16
  lower  = true
  special = false
}

# DB Instance configurations
resource "aws_db_instance" "wordpress-db" {
  identifier              = "${var.environment}-${var.identifier}"
  instance_class          = "${var.instance_class}"
  allocated_storage       = "${var.allocated_storage}"
  engine                  = "${var.engine}"
  db_name                 = "${var.db_name}"
  username                = "${var.wp_db_user}"
  password                = "${random_password.db_password.result}"
  engine_version          = "${var.engine_version}"
  db_subnet_group_name    = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids  = "${var.vpc_security_group_ids}"
  deletion_protection     = "${var.deletion_protection}"
  preferred_backup_window = "${var.preferred_backup_window}"

  tags {
    Name        = "${var.environment}-${var.identifier}"
    Environment = "${var.environment}"
  }
}

# Creates a secretmanager variable to store DB credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.environment}-wp-rds"

  tags {
    Name        = "${var.environment}-wp-rds"
    Environment = "${var.environment}"
  }
}

# Storing the DB creds in Secretmanager with DB details
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_rds_cluster.default.master_username}",
  "password": "${random_password.db_password.result}",
  "host": "${aws_rds_cluster.default.endpoint}",
  "port": ${aws_rds_cluster.default.port},
  "dbName": "${aws_rds_cluster.default.database_name}"
}
EOF
}