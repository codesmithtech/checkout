# Checkout Simple Website

A live install of this repo can be found here: https://checkout.davidsmith.dev 

This project consists of a _very_ simple website and an infrastructure stack to serve that website with scalability in mind.

AWS Lambda has been selected to host the application code as it:

* Allows for future services to be developed that go beyond a static website
* Scales (almost) infinitely, with zero effort from platform engineers
* Consumption based billing keeps costs low when traffic is low
* Administration/maintenance overhead is kept to an absolute minimum

AWS CloudFront is used to deliver static assets from a CDN.

All communication is secured over HTTPS, with certificates being provisioned in ACM by the infrastructure stack.

## Prerequisites

The following items are required prior to deploying the stack:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform CLI](https://www.terraform.io/cli)
* An AWS account with at least 1 public hosted zone in Route53

## Usage

Review the settings available to configure for the project in `infrastructure/variables.tf` and amend them as necessary.

Sensible default have been provided for most variables. The settings that it is critical to review are:

* `aws_profile`
* `app_domain`
* `cdn_domain`
* `ecr_repo_name`

Read the [Terraform documentation](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files) around setting variables.

Next, perform a one-time set up step:

```
cd infrastructure
terraform init
terraform plan -var create_lambda_function=false -out terraform.plan
terraform apply terraform.plan && rm terraform.plan
```


### Making changes

You can make changes to the web application by editing the code in `./checkout-simple-app`, then running the following command to build and push your changes:

```
cd ./checkout-simple-app
./build-and-push.sh 1.3     # 1.3 is the version you want to tag this build with. Should be unique for each build
```

### Deploying a new version

Once the new app version has been built and pushed, run the following command to update the lambda function to use that version.

```
cd infrastructure && terraform apply -var app_version=1.3
```

This will also deploy the static assets for that version to CloudFront

## Logs 

Logs from Lambda function invocations are streamed to AWS CloudWatch. Logs are retained for 30 days

Logs from the ALB (Application Load Balancer) are stored in an S3 bucket. Log files are retained for 7 days


## Improvements

The following is a list of items to be completed:

* Implement build and deploy pipeline in CodePipeline/CodeBuild/CodeDeploy
* Implement monitoring and alerts in CloudWatch

## Real World

In a real-life project, the website (everything in `./checkout-simple-app`) and infrastructure would be in separate repositories.