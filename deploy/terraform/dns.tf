resource "aws_route53_zone" "e10_camp" {
  name = "e10.camp"
}

resource "aws_route53_zone" "e10_video" {
  name = "e10.video"
}

resource "aws_route53_zone" "e10_computer" {
  name = "e10.computer"
}

resource "aws_route53_zone" "e10_llc" {
  name = "e10.llc"
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

resource "aws_route53_zone" "turkeltaub_dev" {
  name = "turkeltaub.dev"
}

resource "aws_route53_zone" "ethnt_me" {
  name = "ethnt.me"
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

resource "aws_route53_record" "root_turkeltaub_me" {
  name    = "turkeltaub.me"
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.turkeltaub_me_website.website_domain
    zone_id                = aws_s3_bucket.turkeltaub_me.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_turkeltaub_me" {
  name    = "www.turkeltaub.me"
  zone_id = aws_route53_zone.turkeltaub_me.zone_id
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.www_turkeltaub_me_website.website_domain
    zone_id                = aws_s3_bucket.www_turkeltaub_me.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root_mx_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "turkeltaub.dev"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "*.turkeltaub.dev"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "fm1._domainkey.turkeltaub.dev"
  type    = "CNAME"
  records = ["fm1.turkeltaub.dev.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "fm2._domainkey.turkeltaub.dev"
  type    = "CNAME"
  records = ["fm2.turkeltaub.dev.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "fm3._domainkey.turkeltaub.dev"
  type    = "CNAME"
  records = ["fm3.turkeltaub.dev.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_turkeltaub_dev" {
  zone_id = aws_route53_zone.turkeltaub_dev.zone_id
  name    = "turkeltaub.dev"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}

resource "aws_route53_record" "root_mx_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "e10.computer"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "*.e10.computer"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "fm1._domainkey.e10.computer"
  type    = "CNAME"
  records = ["fm1.e10.computer.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "fm2._domainkey.e10.computer"
  type    = "CNAME"
  records = ["fm2.e10.computer.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "fm3._domainkey.e10.computer"
  type    = "CNAME"
  records = ["fm3.e10.computer.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_e10_computer" {
  zone_id = aws_route53_zone.e10_computer.zone_id
  name    = "e10.computer"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}

resource "aws_route53_record" "root_mx_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "e10.llc"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "*.e10.llc"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "fm1._domainkey.e10.llc"
  type    = "CNAME"
  records = ["fm1.e10.llc.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "fm2._domainkey.e10.llc"
  type    = "CNAME"
  records = ["fm2.e10.llc.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "fm3._domainkey.e10.llc"
  type    = "CNAME"
  records = ["fm3.e10.llc.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_e10_llc" {
  zone_id = aws_route53_zone.e10_llc.zone_id
  name    = "e10.llc"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}
