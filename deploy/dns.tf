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

resource "aws_route53_record" "monitor" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "monitor.camp.computer"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "grafana.camp.computer"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_zone" "e10_land" {
  name = "e10.land"
}

resource "aws_route53_record" "e10_land" {
  zone_id = aws_route53_zone.e10_land.zone_id
  name    = "e10.land"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}
