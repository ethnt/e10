resource "aws_ses_domain_identity" "e10_camp" {
  domain = "e10.camp"
}

resource "aws_ses_email_identity" "monitor_e10_camp" {
  email = "monitor@e10.camp"
}

resource "aws_ses_email_identity" "alerts_e10_camp" {
  email = "alerts@e10.camp"
}

resource "aws_ses_email_identity" "ethan_turkeltaub_e10_hey_com" {
  email = "ethan.turkeltaub+e10@hey.com"
}

resource "aws_route53_record" "ses_verification" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "_amazonses.e10.camp"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.e10_camp.verification_token]
}

resource "aws_route53_record" "mx_improvmx" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "e10.camp"
  type    = "MX"
  ttl     = 600
  records = ["10 mx1.improvmx.com", "20 mx2.improvmx.com"]
}

resource "aws_route53_record" "txt_improvmv" {
  zone_id = aws_route53_zone.e10_camp.zone_id
  name    = "e10.camp"
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:spf.improvmx.com ~all"]
}

resource "improvmx_domain" "e10_camp" {
  domain = "e10.camp"
}

resource "improvmx_email_forward" "wildcard_e10_camp" {
  domain = "e10.camp"
  alias_name = "*"
  destination_email = "ethan.turkeltaub+e10@hey.com"
}

resource "aws_iam_user" "mailer" {
  name = "mailer"
}

resource "aws_iam_access_key" "mailer" {
  user = aws_iam_user.mailer.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "mailer_ses_sender" {
  user       = aws_iam_user.mailer.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

# output "smtp_username" {
#   value = aws_iam_access_key.mailer.id
# }

# output "smtp_password" {
#   value = aws_iam_access_key.mailer.ses_smtp_password_v4
#   sensitive = true
# }
