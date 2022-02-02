variable "app_version" {
  type        = string
  description = "Version of the app to deploy"
}

variable "aws_profile" {
  type        = string
  description = "Name of the AWS CLI profile to use when provisioning infrastructure"
  default     = "default"
}

variable "ecr_repo_name" {
  type        = string
  description = "Name of the ECR repository for this app. Must be a private ECR repository."
  default     = "checkout-test-website"
}

variable "app_domain" {
  type        = string
  description = "Domain on which the app will be publicly available"
  default     = "checkout.davidsmith.dev"
}

variable "cdn_domain" {
  type        = string
  description = "Domain on which static assets will be published to"
  default     = "checkout-cdn.davidsmith.dev"
}

variable "create_lambda_function" {
  type        = bool
  default     = true
  description = "Whether or not to create a lambda function. Disable this when bootstrapping infrastructure"
}