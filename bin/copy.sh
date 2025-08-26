#!/bin/bash
set -e

append_scanner_script_support() {
    local target_file=$1
    
    cat >> "$target_file" << EOF


# Temporarily copying the current Dockerfile and the version scanner script to generate the installed-versions.json file.
COPY ./generate_versions.sh /usr/local/bin/generate_versions.sh
ARG THIS_DOCKERFILE_NAME=$target_file
COPY \${THIS_DOCKERFILE_NAME} /tmp/target-dockerfile
RUN chmod +x /usr/local/bin/generate_versions_json.sh \\
  && mkdir "\${USER_HOME}/.mend" \\
  && /usr/local/bin/generate_versions_json.sh /tmp/target-dockerfile \\
     > "\${USER_HOME}/.mend/installed-versions.json" \\
  && rm /tmp/target-dockerfile && rm /usr/local/bin/generate_versions_json.sh 
EOF
}

if [ -z "$1" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$1" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
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
append_scanner_script_support "repo-integrations/scanner/Dockerfile"


scaScannerDockerfilefull=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfilefull

if [ ! -f $scaScannerDockerfilefull ]; then
  echo "Error: $scaScannerDockerfilefull not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfilefull > repo-integrations/scanner/Dockerfile.full
append_scanner_script_support "repo-integrations/scanner/Dockerfile.full"


remediateDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-remediate/docker/Dockerfile

if [ ! -f $remediateDockerfile ]; then
  echo "Error: $remediateDockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $remediateDockerfile > repo-integrations/remediate/Dockerfile
