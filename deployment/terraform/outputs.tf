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
output "mysql_dump_command" {
  value = "mysql -h ${module.mysql_database.DBip} -u ${module.mysql_database.DBUsername} -p ${module.mysql_database.DBName} < database.sql"
}
output "domain" {
  value = "final.${var.domain_name}"
}