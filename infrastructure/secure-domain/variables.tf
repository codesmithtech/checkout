variable "domain_name" {
  type        = string
  description = "FQDN of the domain to create"
}

variable "aws_profile" {
  type        = string
  description = "Name of the AWS CLI profile to use when provisioning infrastructure"
}

variable "for_cloudfront" {
  type        = bool
  description = "Flag to indicate whether this domain will be used by CloudFront"
  default     = false
}

locals {
  root_domain = regex("[^\\.]+\\.[a-z]+$", var.domain_name)
  sub_domain  = regex("^[^\\.]+", var.domain_name)
}