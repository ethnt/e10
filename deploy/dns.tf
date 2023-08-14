resource "aws_route53_zone" "e10_camp" {
  name = "e10.camp"
}

resource "aws_route53_record" "gateway" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "gateway.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}
