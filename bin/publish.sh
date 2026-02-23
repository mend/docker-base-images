#!/bin/bash
set -e

RELEASE=$1
REGISTRY_PREFIX=$2
TAG_SUFFIX=${3:-}

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  echo "Usage: $0 <release> <registry_prefix> [tag_suffix]"
  echo "Examples:"
  echo "  $0 1.2.3 \$ECR_REGISTRY         # Push to ECR (default tags)"
  echo "  $0 1.2.3 \$ECR_REGISTRY -arm64  # Push with -arm64 tag suffix"
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

RELEASE_TAG="${RELEASE}${TAG_SUFFIX}"
FULL_TAG="${RELEASE}-full${TAG_SUFFIX}"

echo "Pushing images to registry: ${REGISTRY_PREFIX} (tags: ${RELEASE_TAG}, ${FULL_TAG})"

# Push all images directly
docker push ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE_TAG}
docker push ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE_TAG}
docker push ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE_TAG}
docker push ${REGISTRY_PREFIX}/base-repo-scanner:${FULL_TAG}
docker push ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE_TAG}

echo "All images pushed successfully!"
