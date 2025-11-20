#!/bin/bash
set -e

RELEASE=$1

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$RELEASE" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi

echo "Pushing images to Docker Hub mend/ repository"

docker push mend/base-repo-controller:${RELEASE}
docker push mend/base-repo-remediate:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}
docker push mend/base-repo-scanner:${RELEASE}-full
docker push mend/base-repo-scanner-sast:${RELEASE}
