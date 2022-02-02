#!/usr/bin/env bash
# NOTE: In a real-world system, this would be replaced by a CI/CD pipeline

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "  USAGE: ./build-and-push.sh VERSION"
  exit 2
fi

# In a real-world script, these would be taken from ENV vars, or some other option to allow devs to specify these vars
ACCOUNT_ID=246316657840
AWS_PROFILE=hhd
AWS_REGION=eu-west-1
REPO_URL=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/checkout-test
ASSETS_BUCKET=checkout-test-website-assets

# Build and push the docker image
aws --profile $AWS_PROFILE ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker build -t $REPO_URL:$VERSION .
docker push $REPO_URL:$VERSION


# Upload assets to the bucket that backs our CloudFront distribution
# We'll upload to a subdirectory to force cache busting, and prevent assets from affecting those belonging to other versions
aws --profile $AWS_PROFILE s3 sync ./assets/. "s3://$ASSETS_BUCKET/$VERSION/"