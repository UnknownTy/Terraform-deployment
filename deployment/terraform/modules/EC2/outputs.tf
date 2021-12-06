output "app_ids" {
    value = [
        aws_instance.social_app_1.id,
        aws_instance.social_app_2.id,
        aws_instance.social_app_3.id
    ]
}
output "app_ips" {
    value = [
        aws_instance.social_app_1.private_ip,
        aws_instance.social_app_2.private_ip,
        aws_instance.social_app_3.private_ip
    ]
}