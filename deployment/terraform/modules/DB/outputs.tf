output "DBip" {
  value = aws_db_instance.mysql.address
}
output "DBUsername" {
  value = aws_db_instance.mysql.username
}
output "DBName" {
  value = aws_db_instance.mysql.name
}