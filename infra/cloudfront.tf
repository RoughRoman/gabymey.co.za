# ---------------------------------------------------------------------------
# CloudFront distribution for the static site
# ---------------------------------------------------------------------------

# Origin Access Control — allows CloudFront to access the private S3 bucket
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.site_name}-oac"
  description                       = "OAC for ${var.site_name} site bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Function — rewrites extensionless URI paths to /path/index.html
# so that Astro's static output works correctly (e.g. /writing → /writing/index.html)
resource "aws_cloudfront_function" "uri_rewrite" {
  name    = "gabymey-co-za-uri-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-EOF
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      // If the URI ends with '/', append 'index.html'
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      }
      // If the URI has no file extension, append '/index.html'
      else if (!uri.includes('.', uri.lastIndexOf('/'))) {
        request.uri += '/index.html';
      }

      return request;
    }
  EOF
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  http_version        = "http2and3"

  # No aliases — using the default *.cloudfront.net endpoint for now
  # When a custom domain is added later, add an aliases block here and
  # attach an ACM certificate via the viewer_certificate block.

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.site.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized (AWS managed)

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.uri_rewrite.arn
    }
  }

  # Serve a custom 404 page from the site root
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = var.site_name
  }
}
