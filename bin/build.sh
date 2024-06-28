#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

RELEASE=$1

docker build -t mend/base-repo-controller:${RELEASE} repo-integrations/controller
docker build -t mend/base-repo-remediate:${RELEASE} repo-integrations/remediate
docker build -t mend/base-repo-scanner:${RELEASE} repo-integrations/scanner