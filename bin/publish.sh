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

docker push mend/base-repo-controller:${RELEASE}
docker push mend/base-repo-remediate:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}-full