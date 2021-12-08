variable "db_sg" {
  description = "Database's security group"
  type        = string
}
variable "db_az" {
  description = "Database's availability zone"
  type        = string
}
variable "database_admin_password" {
  description = "Password used to access the DB"
  type        = string
}
variable "rds_private_subnets" {
  description = "Subnets to be used by the RDS system"
  type        = list(any)
}