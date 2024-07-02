#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

RELEASE=$1

docker push mend/base-repo-controller:${RELEASE}
docker push mend/base-repo-remediate:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}-full