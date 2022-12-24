resource "aws_route53_record" "gateway" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "gateway.e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}

resource "aws_route53_record" "monitor" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "monitor.e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "grafana.e10.network"
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

resource "aws_route53_zone" "orchard_run" {
  name = "orchard.run"
}

resource "aws_route53_zone" "satan_network" {
  name = "satan.network"
}

resource "aws_route53_zone" "e10_network" {
  name = "e10.network"
}

resource "aws_route53_record" "e10_network_wildcard" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "*.e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}

resource "aws_route53_zone" "e10_video" {
  name = "e10.video"
}

resource "aws_route53_record" "e10_video_root" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}

resource "aws_route53_record" "e10_video_wildcard" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "*.e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}

resource "aws_route53_record" "pve" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "pve.e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.gateway.public_ip]
}

resource "aws_route53_record" "files" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "files.e10.network"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.files_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.files_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "e10_network_validation" {
  for_each = {
    for dvo in aws_acm_certificate.files_ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.e10_network.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.e10_network.zone_id
}
