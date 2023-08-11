provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "rds_security_group" {
  name_prefix = "rds-security-group"
  description = "Security group for RDS PostgreSQL database"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "terraform_rds_instance" {
  engine              = "postgres"
  engine_version      = "15.3"
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  identifier          = "my-rds-instance"
  username            = var.rds_superuser_name
  password            = var.rds_root_password
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = true

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false


}
