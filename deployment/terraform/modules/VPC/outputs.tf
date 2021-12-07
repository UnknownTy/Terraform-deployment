output "vpc_id" {
    value = aws_vpc.main.id
}
output "priv_ec2_subnets" {
    value = [
        aws_subnet.ec2_priv_subnet_1.id,
        aws_subnet.ec2_priv_subnet_2.id,
        aws_subnet.ec2_priv_subnet_3.id
    ]
}
output "priv_rds_subnets" {
    value = [
        aws_subnet.rds_priv_subnet_1.id,
        aws_subnet.rds_priv_subnet_2.id,
        aws_subnet.rds_priv_subnet_3.id
    ]
}
output "pub_lb_subnets" {
    value = [
        aws_subnet.public_subnet_1.id,
        aws_subnet.public_subnet_2.id,
        aws_subnet.public_subnet_3.id
    ]
}
output "testing_sg_id" {
    value = aws_security_group.testing_group.id
}
output "rds_sg_id" {
    value = aws_security_group.database_sg.id
}
output "ec2_sg_id" {
    value = aws_security_group.private_sg.id
}
output "pub_http_sg_id" {
    value = aws_security_group.public_sg.id
}