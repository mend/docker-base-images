#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

RELEASE=$1

docker pull ubuntu:24.04
docker build --no-cache -t mend/base-repo-controller:${RELEASE} -f repo-integrations/controller/Dockerfile .
docker build --no-cache -t mend/base-repo-remediate:${RELEASE} -f repo-integrations/remediate/Dockerfile .
docker build --no-cache -t mend/base-repo-scanner:${RELEASE} -f repo-integrations/scanner/Dockerfile .
docker build --no-cache -t mend/base-repo-scanner:${RELEASE}-full -f repo-integrations/scanner/Dockerfile.full .
