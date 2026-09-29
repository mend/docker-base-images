#!/bin/bash
set -e

OLD_VERSION=$1
NEW_VERSION=$2
ECR_REGISTRY=$3
TAG_SUFFIX=${4:-}

if [ -z "$OLD_VERSION" ] || [ -z "$NEW_VERSION" ] || [ -z "$ECR_REGISTRY" ]; then
  echo "Error: Missing required arguments."
  echo "Usage: $0 <old_version> <new_version> <ecr_registry> [tag_suffix]"
  exit 1
fi

OLD_TAG="${OLD_VERSION}${TAG_SUFFIX}"
NEW_TAG="${NEW_VERSION}${TAG_SUFFIX}"
OLD_FULL_TAG="${OLD_VERSION}-full${TAG_SUFFIX}"
NEW_FULL_TAG="${NEW_VERSION}-full${TAG_SUFFIX}"

IMAGES=(
  "base-repo-scanner-sast:${OLD_TAG}:${NEW_TAG}"
  "base-repo-scanner:${OLD_TAG}:${NEW_TAG}"
  "base-repo-scanner:${OLD_FULL_TAG}:${NEW_FULL_TAG}"
  "base-repo-remediate:${OLD_TAG}:${NEW_TAG}"
)

echo "🔄 Retagging images from ${OLD_VERSION} → ${NEW_VERSION}"

for entry in "${IMAGES[@]}"; do
  IFS=':' read -r repo old new <<< "$entry"
  src="${ECR_REGISTRY}/${repo}:${old}"
  dst="${ECR_REGISTRY}/${repo}:${new}"

  echo "  Pulling ${src}..."
  docker pull "${src}"

  echo "  Tagging → ${dst}"
  docker tag "${src}" "${dst}"
done

echo "✅ Images retagged successfully (${OLD_VERSION} → ${NEW_VERSION})"
