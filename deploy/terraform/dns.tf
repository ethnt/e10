resource "aws_route53_zone" "e10_camp" {
  name = "e10.camp"
}

resource "aws_route53_zone" "e10_video" {
  name = "e10.video"
}

resource "aws_route53_zone" "e10_land" {
  name = "e10.land"
}

resource "aws_route53_zone" "satan_network" {
  name = "satan.network"
}

resource "aws_route53_record" "root_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "wildcard_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "*.e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "root_e10_land" {
  zone_id = aws_route53_zone.e10_land.zone_id
  name    = "e10.land"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "wildcard_e10_land" {
  zone_id = aws_route53_zone.e10_land.zone_id
  name    = "*.e10.land"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "gateway_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "gateway.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "monitor_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "monitor.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitor.public_ip]
}

resource "aws_route53_record" "grafana_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "grafana.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitor.public_ip]
}

resource "aws_route53_record" "wildcard_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "*.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}
