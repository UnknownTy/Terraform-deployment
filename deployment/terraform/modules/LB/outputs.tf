output "dns_name" {
  value = aws_lb.http_lb.dns_name
}
output "lb_zone_id" {
  value = aws_lb.http_lb.zone_id
}
output "lb_target_arn" {
  value = aws_lb_target_group.app_tg.arn
}