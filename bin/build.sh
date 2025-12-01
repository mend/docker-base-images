#!/bin/bash
set -e

RELEASE=$1
REGISTRY_PREFIX=$2
COPY_VERSIONS_JSON=$3


if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  echo "Usage: $0 <release> <registry_prefix>"
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

echo "Building images with registry prefix: ${REGISTRY_PREFIX}"

docker pull ubuntu:24.04


docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE} -f repo-integrations/scanner/DockerfileSast .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE} -f repo-integrations/controller/Dockerfile .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE} -f repo-integrations/remediate/Dockerfile .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE} -f repo-integrations/scanner/Dockerfile .
docker build --no-cache -t ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE}-full -f repo-integrations/scanner/Dockerfile.full .


#Validate built images successfully created
echo "🔍 Validating built images..."
if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner-sast:${RELEASE} was not built successfully"
  exit 1
fi
echo "✅ SAST scanner image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-controller:${RELEASE} was not built successfully"
  exit 1
fi
echo "✅ Controller image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-remediate:${RELEASE} was not built successfully"
  exit 1
fi
echo "✅ Remediate image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE} 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE} was not built successfully"
  exit 1
fi
echo "✅ SCA scanner image validated"

if [ -z "$(docker images -q ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE}-full 2> /dev/null)" ]; then
  echo "❌ ${REGISTRY_PREFIX}/base-repo-scanner:${RELEASE}-full was not built successfully"
  exit 1
fi

echo "🎉 All images built successfully with prefix: ${ECR_REGISTRY}"
