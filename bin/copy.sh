#!/bin/bash
set -e

# Source validation functions
source ./bin/validate-modifications.sh


append_scanner_script_support() {
    local target_file=$1
    
    cat >> "$target_file" << EOF


# Temporarily copying the current Dockerfile and the version scanner script to generate the installed-versions.json file.
COPY generate_versions_json.sh /usr/local/bin/generate_versions_json.sh
ARG THIS_DOCKERFILE_NAME=$target_file
COPY \${THIS_DOCKERFILE_NAME} /tmp/target-dockerfile
RUN chmod +x /usr/local/bin/generate_versions_json.sh \\
  && mkdir "\${USER_HOME}/.mend" \\
  && /usr/local/bin/generate_versions_json.sh /tmp/target-dockerfile \\
     > "\${USER_HOME}/.mend/installed-versions.json" \\
  && rm /tmp/target-dockerfile && rm /usr/local/bin/generate_versions_json.sh 
EOF
}

# Function to apply Docker file modifications
apply_dockerfile_modifications() {
    local dockerfile=$1
    local config_name=$2
    local config_file="config/${config_name}-modifications.txt"

    if [ -f "$config_file" ] && [ -s "$config_file" ]; then
        echo "Applying modifications to $dockerfile using $config_file"
        ./bin/modify-dockerfile.sh "$dockerfile" "$config_file"
    else
        echo "No modifications configured for $dockerfile (config: $config_file)"
    fi
}

RELEASE=$1
COPY_VERSIONS_JSON=$2

if [ -z "$RELEASE" ]; then
  echo "Error: No release argument provided."
  exit 1
fi

if [ "$RELEASE" = "1.1.1" ]; then
  echo "Error: Default version tag provided. Please provide the correct tag"
  exit 1
fi

echo "release arg: $RELEASE"
echo "COPY_VERSIONS_JSON arg: $COPY_VERSIONS_JSON"

# ================================
# CONTROLLER SERVICE PROCESSING
# ================================
echo "🎯 Processing Controller Service Dockerfile..."
appdockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-ghe-app/docker/Dockerfile

if [ ! -f $appdockerfile ]; then
  echo "Error: $appdockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $appdockerfile > repo-integrations/controller/Dockerfile


# ================================
# SAST SCANNER SERVICE PROCESSING
# ================================
echo "🎯 Processing SAST Scanner Service Dockerfile..."
sastScannerDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/DockerfileSast

if [ ! -f $sastScannerDockerfile ]; then
  echo "Error: $sastScannerDockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $sastScannerDockerfile > repo-integrations/scanner/DockerfileSast

# ================================
# SCA SCANNER SERVICE PROCESSING
# ================================

echo "🎯 Processing SCA Scanner Service Dockerfile..."
scaScannerDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfile

if [ ! -f $scaScannerDockerfile ]; then
  echo "Error: $scaScannerDockerfile not found."
  exit 1
fi

echo "✅ Base image marker found, truncating SCA Dockerfile..."
sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfile > repo-integrations/scanner/Dockerfile

apply_dockerfile_modifications "repo-integrations/scanner/Dockerfile" "scanner"

if [ "$COPY_VERSIONS_JSON" = true ]; then
    append_scanner_script_support "repo-integrations/scanner/Dockerfile"
fi

# ================================
# SCA SCANNER FULL SERVICE PROCESSING
# ================================

echo "🎯 Processing SCA Scanner Full Service Dockerfile..."
scaScannerDockerfilefull=tmp/agent-4-github-enterprise-$RELEASE/wss-scanner/docker/Dockerfilefull

if [ ! -f $scaScannerDockerfilefull ]; then
  echo "Error: $scaScannerDockerfilefull not found."
  exit 1
fi


sed '/# END OF BASE IMAGE/ q' $scaScannerDockerfilefull > repo-integrations/scanner/Dockerfile.full

echo "🔍 Validating SCA full Dockerfile truncation..."
if ! grep -q "# END OF BASE IMAGE" repo-integrations/scanner/Dockerfile.full; then
  echo "❌ ERROR: Truncation failed for SCA full Dockerfile"
  exit 1
fi

apply_dockerfile_modifications "repo-integrations/scanner/Dockerfile.full" "scanner"
if [ "$COPY_VERSIONS_JSON" = true ]; then
    append_scanner_script_support "repo-integrations/scanner/Dockerfile.full"
fi

# ================================
# REMEDIATE SERVICE PROCESSING
# ================================
echo "🎯 Processing Remediate Service Dockerfile..."
remediateDockerfile=tmp/agent-4-github-enterprise-$RELEASE/wss-remediate/docker/Dockerfile

if [ ! -f $remediateDockerfile ]; then
  echo "Error: $remediateDockerfile not found."
  exit 1
fi

sed '/# END OF BASE IMAGE/ q' $remediateDockerfile > repo-integrations/remediate/Dockerfile

apply_dockerfile_modifications "repo-integrations/remediate/Dockerfile" "remediate"

# ================================
# SUMMARY OUTPUT
# ================================
echo ""
echo "📋 Generated Dockerfile Summary:"
echo "=========================================="
echo "📄 Controller Dockerfile:"
cat repo-integrations/controller/Dockerfile
echo ""
echo "📄 SAST Scanner Dockerfile:"
cat repo-integrations/scanner/DockerfileSast
echo ""
echo "📄 SCA Scanner Dockerfile:"
cat repo-integrations/scanner/Dockerfile
echo ""
echo "📄 SCA Scanner Full Dockerfile:"
cat repo-integrations/scanner/Dockerfile.full
echo ""
echo "📄 Remediate Dockerfile:"
cat repo-integrations/remediate/Dockerfile
echo "=========================================="

