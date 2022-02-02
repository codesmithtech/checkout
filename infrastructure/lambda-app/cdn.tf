resource "aws_s3_bucket" "assets" {
  bucket = "checkout-test-website-assets"
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudfront_access_policy" {
  bucket = aws_s3_bucket.assets.id
  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cdn.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.assets.bucket}/*"
        }
    ]
  })
}

resource "aws_route53_record" "cdn_domain" {
  name    = local.cdn_sub_domain
  type    = "A"
  zone_id = var.cdn_cert.zone_id

  alias {
    name = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

locals {
  s3_origin_id = "${var.app_name}-s3-origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.cdn.id}"
    }
  }

  aliases = [var.cdn_domain]

  enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cdn_cert.certificate_arn
    ssl_support_method = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "cdn" {
  comment = "Cloudfront access to assets S3 bucket"
}