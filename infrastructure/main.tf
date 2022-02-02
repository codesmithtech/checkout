terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "eu"
  region  = "eu-west-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  profile = var.aws_profile
}

locals {
  vpc = {
    cidr            = "10.1.0.0/16"
    private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fargate-app-vpc"
  cidr = local.vpc.cidr

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = local.vpc.private_subnets
  public_subnets  = local.vpc.public_subnets

  enable_nat_gateway = false
}

module "cdn_cert" {
  source         = "./secure-domain"
  aws_profile    = var.aws_profile
  domain_name    = var.cdn_domain
  for_cloudfront = true
  providers = {
    aws.certs = aws.us
  }
}

module "app_cert" {
  source      = "./secure-domain"
  aws_profile = var.aws_profile
  domain_name = var.app_domain
  providers = {
    aws.certs = aws.eu
  }
}

module "lambda_app" {
  source = "./lambda-app"

  app_name               = "checkout-test"
  create_lambda_function = var.create_lambda_function
  app_version            = var.app_version
  app_domain             = var.app_domain
  cdn_domain             = var.cdn_domain
  app_cert               = module.app_cert
  cdn_cert               = module.cdn_cert
  ecr_repo_name          = var.ecr_repo_name

  vpc = {
    private_subnets = local.vpc.private_subnets
    public_subnets  = local.vpc.public_subnets
    id              = module.vpc.vpc_id
  }

  depends_on = [module.vpc]
}

