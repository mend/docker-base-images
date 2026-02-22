#!/bin/bash
set -e

RELEASE=$1
REGISTRY_PREFIX=$2
COPY_VERSIONS_JSON=$3
TAG_SUFFIX=${4:-}

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  echo "Usage: $0 <release> <registry_prefix> [copy_versions_json] [tag_suffix]"
  exit 1
fi

if [ "$RELEASE" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi


if [ -z "$REGISTRY_PREFIX" ]; then
  echo "Error: Registry prefix is required for ECR builds"
  exit 1
fi

if [ "$COPY_VERSIONS_JSON" = true ] ; then
    cp tmp/agent-4-github-enterprise-${RELEASE}/wss-scanner/docker/docker-image-scanner/generate_versions_json.sh .
fi

# Tag suffix (e.g. -arm64) for multi-arch; empty means default tags
RELEASE_TAG="${RELEASE}${TAG_SUFFIX}"
FULL_TAG="${RELEASE}-full${TAG_SUFFIX}"

echo "Building images with registry prefix: ${REGISTRY_PREFIX}, tags: ${RELEASE_TAG}, ${FULL_TAG}"

docker pull ubuntu:24.04

# When building for arm64, remediate Dockerfile may default to amd64 base; override for native ARM
REMEDIATE_BASE_ARG=""
if [ "$TAG_SUFFIX" = "-arm64" ]; then
  REMEDIATE_BASE_ARG="--build-arg BASE_IMAGE=ubuntu:24.04"
  # Scanner Dockerfile.full has hardcoded amd64 libssl1.1 URL. Version 1.1.1f-1ubuntu2.24 has no arm64
  # in security.ubuntu.com; use Focal's 1.1.1f-1ubuntu2.22 arm64 from archive.ubuntu.com (same ABI).
  if [ -f repo-integrations/scanner/Dockerfile.full ]; then
    sed -i.bak 's|https://security\.ubuntu\.com/ubuntu/pool/main/o/openssl/libssl1\.1_1\.1\.1f-1ubuntu2\.24_amd64\.deb|https://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_arm64.deb|g' repo-integrations/scanner/Dockerfile.full
  fi
fi

docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE_TAG} -f repo-integrations/scanner/DockerfileSast .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE_TAG} -f repo-integrations/controller/Dockerfile .
docker build --no-cache ${REMEDIATE_BASE_ARG} -t ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE_TAG} -f repo-integrations/remediate/Dockerfile .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE_TAG} -f repo-integrations/scanner/Dockerfile .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner:${FULL_TAG} -f repo-integrations/scanner/Dockerfile.full .


#Validate built images successfully created
echo "🔍 Validating built images..."
if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE_TAG} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE_TAG} was not built successfully"
  exit 1
fi
echo "✅ SAST scanner image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE_TAG} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE_TAG} was not built successfully"
  exit 1
fi
echo "✅ Controller image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE_TAG} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE_TAG} was not built successfully"
  exit 1
fi
echo "✅ Remediate image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE_TAG} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE_TAG} was not built successfully"
  exit 1
fi
echo "✅ SCA scanner image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner:${FULL_TAG} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner:${FULL_TAG} was not built successfully"
  exit 1
fi

echo "🎉 All images built successfully with prefix: ${REGISTRY_PREFIX}"
