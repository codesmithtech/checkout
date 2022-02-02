variable "app_version" {
  type = string
  description = "Version of the app to deploy"
}

variable "aws_profile" {
  type = string
  description = "Name of the AWS CLI profile to use when provisioning infrastructure"
  default = "default"
}

variable "docker_image_repo_url" {
  type = string
  description = "URL of the docker image repository for this app. Must be a private ECR repository. DO NOT INCLUDE the image tag here. (use app_version)"
  default = "246316657840.dkr.ecr.eu-west-1.amazonaws.com/checkout-test-website"
}

variable "app_domain" {
  type = string
  description = "Domain on which the app will be publicly available"
  default = "checkout.davidsmith.dev"
}

variable "cdn_domain" {
  type = string
  description = "Domain on which static assets will be published to"
  default = "checkout-cdn.davidsmith.dev"
}

variable "create_lambda_function" {
  type = bool
  default = true
  description = "Whether or not to create a lambda function. Disable this when bootstrapping infrastructure"
}