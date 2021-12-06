variable "region" {
  description = "The AWS region where the infrastructure will be deployed"
  type        = string
}
variable "database_admin_password" {
  description = "Password to be used to connect to the RDS Database"
  type        = string
}