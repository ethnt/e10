# e10.video

resource "aws_route53_zone" "e10_video" {
  name = "e10.video"
}

resource "porkbun_nameservers" "e10_video" {
  domain      = "e10.video"
  nameservers = sort(aws_route53_zone.e10_video.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "status_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "status.e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "wildcard_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "*.e10.video"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "em824837_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "em824837.e10.video"
  type    = "CNAME"
  records = ["return.smtp2go.net"]
  ttl     = 300
}

resource "aws_route53_record" "s824837_domainkey_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "s824837._domainkey.e10.video"
  type    = "CNAME"
  records = ["dkim.smtp2go.net"]
  ttl     = 300
}

resource "aws_route53_record" "link_email_e10_video" {
  zone_id = aws_route53_zone.e10_video.zone_id
  name    = "link.email.e10.video"
  type    = "CNAME"
  records = ["track.smtp2go.net"]
  ttl     = 300
}

# e10.land

resource "aws_route53_zone" "e10_land" {
  name = "e10.land"
}

resource "porkbun_nameservers" "e10_land" {
  domain      = "e10.land"
  nameservers = sort(aws_route53_zone.e10_land.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_e10_land" {
  zone_id = aws_route53_zone.e10_land.zone_id
  name    = "e10.land"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "wildcard_e10_land" {
  zone_id = aws_route53_zone.e10_land.zone_id
  name    = "*.e10.land"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

# e10.camp

resource "aws_route53_zone" "e10_camp" {
  name = "e10.camp"
}

resource "porkbun_nameservers" "e10_camp" {
  domain      = "e10.camp"
  nameservers = sort(aws_route53_zone.e10_camp.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "bastion_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "bastion.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "monitor_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "monitor.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "grafana_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "grafana.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "status_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "status.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "ntfy_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "ntfy.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "healthchecks_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "healthchecks.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.monitor.public_ip]
}

resource "aws_route53_record" "wildcard_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "*.e10.camp"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "em824837_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "em824837.e10.camp"
  type    = "CNAME"
  records = ["return.smtp2go.net"]
  ttl     = 300
}

resource "aws_route53_record" "s824837_domainkey_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "s824837._domainkey.e10.camp"
  type    = "CNAME"
  records = ["dkim.smtp2go.net"]
  ttl     = 300
}

resource "aws_route53_record" "link_email_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "link.email.e10.camp"
  type    = "CNAME"
  records = ["track.smtp2go.net"]
  ttl     = 300
}

resource "aws_route53_record" "auth_monitor_e10_camp" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "auth.monitor.e10.camp"
  type    = "A"
  records = [aws_eip.monitor.public_ip]
  ttl     = 300
}

# satan.network

resource "aws_route53_zone" "satan_network" {
  name = "satan.network"
}

resource "porkbun_nameservers" "satan_network" {
  domain      = "satan.network"
  nameservers = sort(aws_route53_zone.satan_network.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "unifi_satan_network" {
  zone_id = aws_route53_zone.satan_network.zone_id
  name    = "unifi.satan.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

# e10.network

resource "aws_route53_zone" "e10_network" {
  name = "e10.network"
}

resource "porkbun_nameservers" "e10_network" {
  domain      = "e10.network"
  nameservers = sort(aws_route53_zone.e10_network.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_e10_network" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "wildcard_e10_network" {
  zone_id = aws_route53_zone.e10_network.zone_id
  name    = "*.e10.network"
  type    = "A"
  ttl     = 300
  records = [aws_eip.bastion.public_ip]
}

# turkeltaub.me

resource "aws_route53_zone" "turkeltaub_me" {
  name = "turkeltaub.me"
}

resource "porkbun_nameservers" "turkeltaub_me" {
  domain      = "turkeltaub.me"
  nameservers = sort(aws_route53_zone.turkeltaub_me.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
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

# turkeltaub.dev

resource "aws_route53_zone" "turkeltaub_dev" {
  name = "turkeltaub.dev"
}

resource "porkbun_nameservers" "turkeltaub_dev" {
  domain      = "turkeltaub.dev"
  nameservers = sort(aws_route53_zone.turkeltaub_dev.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
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

# e10.computer

resource "aws_route53_zone" "e10_computer" {
  name = "e10.computer"
}

resource "porkbun_nameservers" "e10_computer" {
  domain      = "e10.computer"
  nameservers = sort(aws_route53_zone.e10_computer.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
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

# e10.llc

resource "aws_route53_zone" "e10_llc" {
  name = "e10.llc"
}

resource "porkbun_nameservers" "e10_llc" {
  domain      = "e10.llc"
  nameservers = sort(aws_route53_zone.e10_llc.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

# turkeltaub.net

resource "aws_route53_zone" "turkeltaub_net" {
  name = "turkeltaub.net"
}

resource "porkbun_nameservers" "turkeltaub_net" {
  domain      = "turkeltaub.net"
  nameservers = sort(aws_route53_zone.turkeltaub_net.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_mx_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "turkeltaub.net"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "*.turkeltaub.net"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "fm1._domainkey.turkeltaub.net"
  type    = "CNAME"
  records = ["fm1.turkeltaub.net.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "fm2._domainkey.turkeltaub.net"
  type    = "CNAME"
  records = ["fm2.turkeltaub.net.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "fm3._domainkey.turkeltaub.net"
  type    = "CNAME"
  records = ["fm3.turkeltaub.net.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_turkeltaub_net" {
  zone_id = aws_route53_zone.turkeltaub_net.zone_id
  name    = "turkeltaub.net"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}

# turkeltaub.org

resource "aws_route53_zone" "turkeltaub_org" {
  name = "turkeltaub.org"
}

resource "porkbun_nameservers" "turkeltaub_org" {
  domain      = "turkeltaub.org"
  nameservers = sort(aws_route53_zone.turkeltaub_org.name_servers)

  lifecycle {
    ignore_changes = [nameservers]
  }
}

resource "aws_route53_record" "root_mx_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "turkeltaub.org"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "wildcard_mx_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "*.turkeltaub.org"
  type    = "MX"
  records = ["10 in1-smtp.messagingengine.com", "20 in2-smtp.messagingengine.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm1_domainkey_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "fm1._domainkey.turkeltaub.org"
  type    = "CNAME"
  records = ["fm1.turkeltaub.org.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm2_domainkey_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "fm2._domainkey.turkeltaub.org"
  type    = "CNAME"
  records = ["fm2.turkeltaub.org.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "fm3_domainkey_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "fm3._domainkey.turkeltaub.org"
  type    = "CNAME"
  records = ["fm3.turkeltaub.org.dkim.fmhosted.com"]
  ttl     = 300
}

resource "aws_route53_record" "spf_turkeltaub_org" {
  zone_id = aws_route53_zone.turkeltaub_org.zone_id
  name    = "turkeltaub.org"
  type    = "TXT"
  records = ["v=spf1 include:spf.messagingengine.com ?all"]
  ttl     = 300
}
