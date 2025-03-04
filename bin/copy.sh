#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

RELEASE=$1

appdockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-ghe-app/docker/Dockerfile

if [ ! -f $appdockerfile ]; then
  echo "Error: $appdockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $appdockerfile > repo-integrations/controller/Dockerfile

scaScannerDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfile

if [ ! -f $scaScannerDockerfile ]; then
  echo "Error: $scaScannerDockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfile > repo-integrations/scanner/Dockerfile

scaScannerDockerfilefull=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfilefull

if [ ! -f $scaScannerDockerfilefull ]; then
  echo "Error: $scaScannerDockerfilefull not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfilefull > repo-integrations/scanner/Dockerfile.full

remediateDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-remediate/docker/Dockerfile

if [ ! -f $remediateDockerfile ]; then
  echo "Error: $remediateDockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $remediateDockerfile > repo-integrations/remediate/Dockerfile