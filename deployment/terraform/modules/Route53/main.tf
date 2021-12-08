resource "aws_acm_certificate" "cert" {
  domain_name       = "final.${var.domain_name}"
  validation_method = "DNS"
}
data "aws_route53_zone" "main" {
  name = var.domain_name
}
resource "aws_route53_record" "final" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "final.${var.domain_name}"
  type            = "A"

  alias {
    name                   = var.lb_ip
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "complete" {
  certificate_arn = aws_acm_certificate.cert.arn
}