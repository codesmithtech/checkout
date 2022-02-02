variable "app_version" {
  type        = string
  description = "Version of the application to deploy. Maps 1:1 to the tag of the docker image to deploy"
}

variable "app_name" {
  type        = string
  description = "System name that can be used to identify this app"
}

variable "docker_image_repo_url" {
  type        = string
  description = "URL of the docker image repository for this app. DO NOT INCLUDE the image tag here. (use app_version)"
  default     = "246316657840.dkr.ecr.eu-west-1.amazonaws.com/checkout-test-website"
}

variable "app_domain" {
  type        = string
  description = "Domain on which the app will be publicly available"
  default     = "checkout.davidsmith.dev"
}

variable "app_path" {
  type        = string
  description = "URL path that the app will be available at"
  default     = "/"
}

variable "cdn_domain" {
  type        = string
  description = "Domain on which static assets will be published to"
  default     = "checkout-cdn.davidsmith.dev"
}

variable "cdn_path" {
  type        = string
  description = "URL path that static assets will be available under"
  default     = "/"
}

variable "assets_dir" {
  type        = string
  description = "Relative path to the directory in the app repository that contains static assets"
  default     = "assets"
}

variable "vpc" {
  type = object({
    id              = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
  description = "Details about the VPC the app should run in"
}

variable "create_lambda_function" {
  type    = bool
  default = true
}

variable "app_cert" {
  description = "Details of the SSL certificate issued for the app's primary domain"
  type = object({
    certificate_arn = string
    zone_id         = string
  })
}

variable "cdn_cert" {
  description = "Details of the SSL certificate issued for the app's CDN domain"
  type = object({
    certificate_arn = string
    zone_id         = string
  })
}

locals {
  app_root_domain = regex("[^\\.]+\\.[a-z]+$", var.app_domain)
  app_sub_domain  = regex("^[^\\.]+", var.app_domain)
  cdn_root_domain = regex("[^\\.]+\\.[a-z]+$", var.cdn_domain)
  cdn_sub_domain  = regex("^[^\\.]+", var.cdn_domain)
}