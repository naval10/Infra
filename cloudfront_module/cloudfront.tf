variable "elb_dns_name" {
  type = string
}

resource "aws_cloudfront_distribution" "elb_distribution" {
  enabled = true

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  origin {
    domain_name = var.elb_dns_name
    origin_id   = var.elb_dns_name

    custom_origin_config {
      http_port               = 80
      https_port              = 443
      origin_protocol_policy  = "http-only"
      origin_ssl_protocols    = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods           = ["GET", "HEAD"]
    cached_methods            = ["GET", "HEAD"]
    target_origin_id          = var.elb_dns_name
    viewer_protocol_policy    = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

