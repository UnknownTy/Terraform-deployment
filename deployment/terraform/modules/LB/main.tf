# Create An Application Load Balancer
resource "aws_lb" "http_lb" {
  name               = "http-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false
}

# Listen for requests on port 443 and forward those requests to the target group
resource "aws_lb_listener" "front_end_secure" {
  load_balancer_arn = aws_lb.http_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Create a target group that will send traffic over port 8080
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# This is an EXAMPLE of how to attach individual instances to the load balancer
// # Direct the traffic to the ec2 instance
// resource "aws_lb_target_group_attachment" "app_attachment_1" {
//   port             = 8080
//   target_group_arn = aws_lb_target_group.app_tg.arn
//   # The id of the ec2 instance:
//   target_id        = var.instance_ids[0]
// }