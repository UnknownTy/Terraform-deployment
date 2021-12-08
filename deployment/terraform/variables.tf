variable "region" {
  description = "The AWS region where the infrastructure will be deployed"
  type        = string
}
variable "database_admin_password" {
  description = "Password to be used to connect to the RDS Database"
  type        = string
}
variable "bucket_name" {
  description = "Name of the bucket to be used"
  type        = string
}
variable "domain_name" {
  description = "Domain name to be connected to the server"
  type        = string
}
variable "ssh_key" {
  description = "SSH Key to connect to the test instance"
  type = string
}