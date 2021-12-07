output "dns_name" {
  value = module.load_balancer.dns_name
}
output "db_ip" {
  value = module.mysql_database.DBip
}
output "db_username" {
  value = module.mysql_database.DBUsername
}
output "db_name" {
  value = module.mysql_database.DBName
}