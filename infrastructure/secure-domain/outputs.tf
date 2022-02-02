output "domain_fqdn" {
  value = var.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.ssl_cert.certificate_arn
}

output "zone_id" {
  value = data.aws_route53_zone.domain.zone_id
}