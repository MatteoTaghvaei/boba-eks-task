# RDS subnet group
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "${local.DEFAULT_NAME}-mysql-subnet-group"
  subnet_ids = local.PRIVATE_SUBNETS_ID

  tags = {
    Name = "${local.DEFAULT_NAME}-mysql-subnet-group"
  }
}

# MySQL instance
resource "aws_db_instance" "mysql" {
  identifier = "${local.DEFAULT_NAME}-mysql"

  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  multi_az            = true
  publicly_accessible = false

  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "${local.DEFAULT_NAME}-mysql"
  }
}