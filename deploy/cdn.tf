resource "aws_cloudfront_distribution" "files_distribution" {
  origin {
    domain_name = aws_s3_bucket.files.bucket_regional_domain_name
    origin_id   = "S3-files.e10.network"
    # origin_access_control_id = aws_cloudfront_origin_access_control.default.id

    # custom_origin_config {
    #   http_port              = 80
    #   https_port             = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["files.e10.network"]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-files.e10.network"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.files_cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
