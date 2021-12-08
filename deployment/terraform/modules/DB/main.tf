resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = var.rds_private_subnets
}

resource "aws_db_instance" "mysql" {
  allocated_storage     = 20
  max_allocated_storage = 0
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t2.micro"

  name     = "social_something"
  username = "party_people"
  password = var.database_admin_password

  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  deletion_protection    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.db_sg]
  availability_zone      = var.db_az
}