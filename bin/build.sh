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


cp tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/docker-image-scanner/generate_versions_json.sh repo-integrations/scanner/

docker pull ubuntu:24.04
docker build --no-cache -t mend/base-repo-controller:${RELEASE} -f repo-integrations/controller/Dockerfile .
docker build --no-cache -t mend/base-repo-remediate:${RELEASE} -f repo-integrations/remediate/Dockerfile .
docker build --no-cache -t mend/base-repo-scanner:${RELEASE} -f repo-integrations/scanner/Dockerfile .
docker build --no-cache -t mend/base-repo-scanner:${RELEASE}-full -f repo-integrations/scanner/Dockerfile.full .


#Validate built images successfully created
if [ -z "$(docker images -q mend/base-repo-controller:${RELEASE} 2> /dev/null)" ]; then
  echo "mend/base-repo-controller:${RELEASE} was not built successfully"
  exit 1
fi
if [ -z "$(docker images -q mend/base-repo-remediate:${RELEASE} 2> /dev/null)" ]; then
  echo "mend/base-repo-remediate:${RELEASE} was not built successfully"
  exit 1
fi
if [ -z "$(docker images -q mend/base-repo-scanner:${RELEASE} 2> /dev/null)" ]; then
  echo "mend/base-repo-scanner:${RELEASE} was not built successfully"
  exit 1
fi
if [ -z "$(docker images -q mend/base-repo-scanner:${RELEASE}-full 2> /dev/null)" ]; then
  echo "mend/base-repo-scanner:${RELEASE}-full was not built successfully"
  exit 1
fi

