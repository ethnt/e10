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

resource "aws_route53_zone" "turkeltaub_me" {
  name = "turkeltaub.me"
}

resource "aws_route53_record" "root_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_instance.gateway.public_ip]
}

resource "aws_route53_record" "status_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "status.e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitor.public_ip]
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

resource "aws_route53_record" "status_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "status.e10.camp"
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

resource "aws_route53_record" "root_mx_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "turkeltaub.me"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "*.turkeltaub.me"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "fm1._domainkey.turkeltaub.me"
  type    = "CNAME"
  records = ["fm1.turkeltaub.me.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "fm2._domainkey.turkeltaub.me"
  type    = "CNAME"
  records = ["fm2.turkeltaub.me.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "fm3._domainkey.turkeltaub.me"
  type    = "CNAME"
  records = ["fm3.turkeltaub.me.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_turkeltaub_me" {
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  name    = "turkeltaub.me"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}
