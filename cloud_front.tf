locals {
  cloudfront_frontend_origin_id = "${var.app_name}-frontend-origin"
  cloudfront_backend_origin_id = "${var.app_name}-backend-origin"
}

resource "aws_cloudfront_distribution" "cloud_front_distribution" {
  enabled = true
  is_ipv6_enabled = true
  comment = "The ${var.app_name} frontend"
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.s3-frontend.bucket_domain_name
    origin_id = local.cloudfront_frontend_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = aws_elastic_beanstalk_environment.mathenger-env.cname
    origin_id = local.cloudfront_backend_origin_id
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      headers = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    target_origin_id = local.cloudfront_frontend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress = true
  }
  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods = ["HEAD", "GET", "OPTIONS"]
    path_pattern = "api/*"
    target_origin_id = local.cloudfront_backend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    min_ttl = 0
    default_ttl = 0
    max_ttl = 0
    forwarded_values {
      query_string = true
      headers = ["*"]
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
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  custom_error_response {
    error_code = 404
    error_caching_min_ttl = 300
    response_code = 404
    response_page_path = "/index.html"
  }
  custom_error_response {
    error_code = 403
    error_caching_min_ttl = 300
    response_code = 403
    response_page_path = "/index.html"
  }
}
