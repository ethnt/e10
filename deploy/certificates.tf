resource "aws_acm_certificate" "files_ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = "files.e10.network"
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "files_cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.files_ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.e10_network_validation : record.fqdn]
}
