#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$1" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi

RELEASE=$1

# Tag all images for ECR
docker tag mend/base-repo-controller:${RELEASE} $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-controller:${RELEASE}
docker tag mend/base-repo-remediate:${RELEASE} $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-remediate:${RELEASE}
docker tag mend/base-repo-scanner:${RELEASE} $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner:${RELEASE}
docker tag mend/base-repo-scanner:${RELEASE}-full $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner:${RELEASE}-full
docker tag mend/base-repo-scanner-sast:${RELEASE} $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner-sast:${RELEASE}

# Push all images to ECR
docker push $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-controller:${RELEASE}
docker push $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-remediate:${RELEASE}
docker push $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner:${RELEASE}
docker push $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner:${RELEASE}-full
docker push $ECR_REGISTRY/$ECR_REPOSITORY/base-repo-scanner-sast:${RELEASE}
