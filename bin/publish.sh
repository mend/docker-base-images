#!/bin/bash
set -ex

RELEASE=$1
REGISTRY_PREFIX=$2

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  echo "Usage: $0 <release> <registry_prefix>"
  echo "Examples:"
  echo "  $0 1.2.3 \$ECR_REGISTRY/\$ECR_REPOSITORY         # Push to ECR"
  exit 1
fi

if [ "$RELEASE" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi

if [ -z "$REGISTRY_PREFIX" ]; then
  echo "Error: Registry prefix is required"
  exit 1
fi

echo "Pushing images to registry: ${REGISTRY_PREFIX}"

# Push all images directly
docker push ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE}
docker push ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE}
docker push ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE}
docker push ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE}-full
docker push ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE}

echo "All images pushed successfully!"
