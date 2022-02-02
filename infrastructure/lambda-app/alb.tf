resource "aws_route53_record" "app_domain" {
  name    = local.app_sub_domain
  type    = "A"
  zone_id = var.app_cert.zone_id

  alias {
    name = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_https.id]
  subnets            = data.aws_subnet_ids.public_subnets.ids
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc.id

  filter {
    name = "cidr-block"
    values = var.vpc.public_subnets
  }
}

resource "aws_lb_listener" "web_traffic" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.app_cert.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_lambda_target.arn
  }
}

resource "aws_lb_target_group" "app_lambda_target" {
  name        = "${var.app_name}-lambda"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "app_lambda_target" {
  count = var.create_lambda_function ? 1 : 0
  target_group_arn = aws_lb_target_group.app_lambda_target.arn
  target_id        = aws_lambda_function.app[0].arn
  depends_on       = [aws_lambda_permission.with_alb]
}

resource "aws_lambda_permission" "with_alb" {
  count = var.create_lambda_function ? 1 : 0
  statement_id  = "AllowExecutionFromAlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app[0].arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.app_lambda_target.arn
}

resource "aws_security_group" "public_https" {
  vpc_id = var.vpc.id

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "TCP"
    to_port   = 65535
    cidr_blocks = var.vpc.private_subnets
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket_prefix = "checkout-test-alb-logs"
  force_destroy = true

  lifecycle_rule {
    id      = "logs-7-day"
    enabled = true

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_policy" "alb_bucket_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::156460612806:root"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}/AWSLogs/*"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}/AWSLogs/*",
        "Condition": {
          "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}"
      }
    ]
  })
}
