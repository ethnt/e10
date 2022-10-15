resource "aws_route53_zone" "primary" {
  name = "camp.computer"
}

resource "aws_route53_record" "gateway" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "gateway.camp.computer"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}
